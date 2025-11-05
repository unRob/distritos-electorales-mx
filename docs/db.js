// SPDX-License-Identifier: Apache-2.0
// Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>
class SQLite {
  constructor () {
    self.conn = null
  }

  async init() {
    const sqlite3 = await window.sqlite3InitModule()

    console.info("db: fetching")
    const res = await fetch('distritos.db')
    const data = await res.arrayBuffer()
    console.info(`db: fetched distritos.db`)

    const p = sqlite3.wasm.allocFromTypedArray(data)
    self.conn = new sqlite3.oo1.DB()
    const rc = sqlite3.capi.sqlite3_deserialize(
      self.conn.pointer, 'main', p, data.byteLength, data.byteLength,
      sqlite3.capi.SQLITE_DESERIALIZE_FREEONCLOSE
    )
    self.conn.checkRc(rc)
    console.info("db: ready")
  }

  async query(lat, lng) {
    console.info(`query: start: ${lat}, ${lng}`)

    const result = self.conn.exec({
      sql: `SELECT
  id,
  entidad,
  localidad,
  tipo,
  ine_id,
  geopoly_json(_shape) geom
FROM
  distrito
WHERE
  geopoly_contains_point(_shape, ?, ? );`,
      bind: [lng, lat],
      rowMode: 'object',
      returnValue: "resultRows"
    })
    console.info(`query: returned ${result.length} results`)

    return result.map(row => {
      const geom = JSON.parse(row.geom)
      delete row.geom
      return {
        "type": "Feature",
        "properties": row,
        "geometry": {
          "type": "Polygon",
          "coordinates": [geom]
        }
      }
    })
  }
}

class DuckDB {
  constructor(){
    self.conn = null
  }

  async init() {
    console.info("db: fetching")
    const res = await fetch('distritos.duckdb')
    const data = await res.arrayBuffer()
    console.info(`db: fetched distritos.duckdb`)

    const JSDELIVR_BUNDLES = ddb.getJsDelivrBundles();
    const bundle = await ddb.selectBundle(JSDELIVR_BUNDLES);
    const worker_url = URL.createObjectURL(
      new Blob([`importScripts("${bundle.mainWorker}");`], {
            type: "text/javascript",
        })
    );
    const worker = new Worker(worker_url);
    // const worker = await ddb.createWorker(bundle.mainWorker);
    const logger = new ddb.ConsoleLogger();
    console.info("db: initializing")
    const db = new ddb.AsyncDuckDB(logger, worker);
    console.info("db: instantiating")
    await db.instantiate(bundle.mainModule);
    URL.revokeObjectURL(worker_url);
    console.info("db: connecting")

    const conn = await db.connect();
    console.info("db: connected")
    try {
      const uint8Array = new Uint8Array(data);
      await db.registerFileBuffer('distritos.duckdb', uint8Array);
    } catch (err) {
      console.error(`Could not register file: ${err}`)
    }
    self.conn = conn

    try {
      await conn.query(`
        INSTALL spatial;
        LOAD spatial;
        ATTACH 'distritos.duckdb' AS ddb;
      `)
    } catch (err) {
      console.error(`db: could not attach: ${err}`)
    }
  }

  async query(lat, lng) {
    const result = await self.conn.query(`
      SELECT
        cast(id as integer) id,
        cast(entidad as integer) entidad,
        cast(distrito_federal as integer) distrito_federal,
        cast(distrito_local as integer) distrito_local,
        cast(tipo as integer) tipo,
        ST_AsGeoJSON(geom) geom
      FROM
        ddb.seccion
      WHERE
        ST_Contains(geom, ST_Point(${lng}, ${lat}));
    `);

    return result.toArray().map(row => {
      let r = Object.assign({}, row)
      const geom = JSON.parse(r.geom)
      delete r.geom
      return {
        "type": "Feature",
        "properties": r,
        "geometry": geom
      }
    })
  }
}
