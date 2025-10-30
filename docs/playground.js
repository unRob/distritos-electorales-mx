// SPDX-License-Identifier: Apache-2.0
// Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>
const desiredAccuracy = 50
let watch;
let db;

const query = `SELECT
  id,
  entidad,
  localidad,
  tipo,
  ine_id
FROM
  distrito
WHERE
  geopoly_contains_point(_shape, ?, ? );`

const watchOptions = {
  enableHighAccuracy: true,
  maximumAge: 60000,
  timeout: 30000,
};

const $findme = document.querySelector("#find-me")
const $playground = document.querySelector("#playground")
const $lat = document.querySelector("#lat")
const $lng = document.querySelector("#lng")
const $accuracy = document.querySelector("#accuracy")

function findme(evt) {
  evt.preventDefault()
  $findme.disabled = true
  if (!watch) {
    console.info("location: watch began")
    watch = navigator.geolocation.watchPosition(foundme, findError, watchOptions)
  }
}

function findError(err) {
  $findme.disabled = false
  navigator.geolocation.clearWatch(watch)
  alert(`Could not get position: ${err}`)
}

async function foundme({coords: {latitude, longitude, accuracy}}) {


  $lat.innerText = latitude
  $lng.innerText = longitude
  $accuracy.innerText = accuracy
  console.info(`location: acquired ${latitude}, ${longitude} (${accuracy})`)
  if (accuracy <= desiredAccuracy) {
    console.info(`location: desired accuracy met or supassed`)
    navigator.geolocation.clearWatch(watch)
    $findme.disabled = false
    await distritos(latitude, longitude)
  }
}

async function distritos(lat, lng) {
  const $distritos = document.querySelector('#distritos')
  console.info(`query: start: ${lat}, ${lng}`)
  $distritos.innerHTML = "";

  const result = db.exec({
    sql: query,
    bind: [lng, lat],
    rowMode: 'object',
    returnValue: "resultRows"
  })
  console.info(`query: returned ${result.length} results`)

  for (row of result) {
    let li = document.createElement("li")
    let code = document.createElement("code")
    code.innerText = JSON.stringify(row, null, " ")
    console.log(row, code.innerText)
    li.appendChild(code)
    $distritos.appendChild(li)
  }
  console.info(`query: complete`)
}


document.addEventListener('readystatechange', async function(evt){
  if (evt.target.readyState != "complete") {
    console.debug(`readystate: ${evt.target.readyState}`)
    return;
  }
  if (!("geolocation" in navigator)) {
    alert("geolocation not available in this browser")
    $findme.disabled = true
  }

  $findme.addEventListener('click', findme)

  $playground.style.opacity = .5

  const sqlite3 = await window.sqlite3InitModule()

  console.info("db: fetching")
  const res = await fetch('distritos.db')
  const data = await res.arrayBuffer()
  console.info(`db: fetched distritos.db`)

  const p = sqlite3.wasm.allocFromTypedArray(data)
  db = new sqlite3.oo1.DB()
  const rc = sqlite3.capi.sqlite3_deserialize(
    db.pointer, 'main', p, data.byteLength, data.byteLength,
    sqlite3.capi.SQLITE_DESERIALIZE_FREEONCLOSE
  )
  db.checkRc(rc)
  $playground.style.opacity = 1
  console.info("db: ready")
})


