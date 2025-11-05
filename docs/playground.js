// SPDX-License-Identifier: Apache-2.0
// Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>
const desiredAccuracy = 50
let watch;
let db;
let map;
let marker = new L.marker(new L.LatLng(0,0), {draggable: 'true'});
let overlay = new L.LayerGroup();

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
const $resolution = document.querySelector("#resolution")

async function locationAcquired(latitude, longitude, accuracy=null) {
  map.setView([latitude, longitude], 15);
  $lat.innerText = latitude
  $lng.innerText = longitude
  if (accuracy) {
    $accuracy.innerText = accuracy
    $resolution.style.display = 'block'
  } else {
    $resolution.style.display = 'none'
  }

  console.info(`location: acquired ${latitude}, ${longitude} (${accuracy})`)
  if (accuracy <= desiredAccuracy) {
    console.info(`location: desired accuracy met or supassed`)
    navigator.geolocation.clearWatch(watch)
    $findme.disabled = false
    marker.setLatLng(new L.LatLng(latitude, longitude),{draggable:'true'});
    try {
      results = await db.query(latitude, longitude)
      await render(results)
    } catch(err) {
      console.error(err)
    }
  }
}

async function render(result) {
  const $distritos = document.querySelector('#distritos')
  console.info(`render: start`)
  $distritos.innerHTML = "";
  map.removeLayer(overlay)

  overlay = new L.LayerGroup().addTo(map)
  for (row of result) {
    let li = document.createElement("li")
    let code = document.createElement("code")

    code.innerText = JSON.stringify(row.properties, null, " ")

    li.appendChild(code)
    $distritos.appendChild(li)

    try {
      console.debug("rendering geojson", JSON.stringify(row))
      overlay.addLayer(L.geoJSON(row, {
        "color": row.properties.localidad == "federal" ? "#ff7800" : "#78ff00",
        "weight": 5,
        "opacity": 0.65,
        onEachFeature: (feature, layer) =>{
          if (feature.properties) {
            layer.bindPopup(JSON.stringify(feature.properties))
          }
          map.fitBounds(layer.getBounds())
        }
      }))
    } catch(err) {
      console.error("Could not render geojson", err)
    }
  }
  console.info(`render: complete`)
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

  map = L.map('map').setView([22.253651, -101.996977], 4);
  map.on('click', async (evt) => {
    marker.setLatLng(evt.latlng,{draggable:'true'})
    await locationAcquired(evt.latlng.lat, evt.latlng.lng)
  })
  map.addLayer(marker)
  map.addLayer(overlay)
  marker.on('dragend', async (event) =>{
    const marker = event.target;
    const position = marker.getLatLng();
    marker.setLatLng(new L.LatLng(position.lat, position.lng),{draggable:'true'});
    await locationAcquired(position.lat, position.lng)
  });

  // L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  L.tileLayer.wms('https://gaiamapas2.inegi.org.mx/mdmCache/service/wms?', {
    layers: 'MapaBaseTopograficov61_sinsombreado',
    attribution: '&copy; <a href="https://inegi.org.mx">INEGI</a>'
  }).addTo(map)

  $findme.addEventListener('click', async (evt) => {
    evt.preventDefault()
    $findme.disabled = true
    if (!watch) {
      console.info("location: watch began")
      watch = navigator.geolocation.watchPosition(
        async (evt) => {
          try {
            await locationAcquired(evt.coords.latitude, evt.coords.longitude, evt.coords.accuracy)
          } catch(err) {
            console.error("Could not find location", err)
          }
          $findme.disabled = false
          watch = null
        }, err => {
          $findme.disabled = false
          navigator.geolocation.clearWatch(watch)
          alert(`Could not get position: ${err}`)
          watch = null
        },
        watchOptions
      )
    }
  })


  $playground.style.opacity = .5
  switch(window.DTO_DB) {
    case "sqlite":
      db = new SQLite()
      await db.init()
      break
    case "duckdb":
      db = new DuckDB()
      await db.init()
      break
    default:
      alert(`unknwon db: ${window.DTO_DB}`);
      return
  }
  $playground.style.opacity = 1
  $resolution.style.display = 'none';
  console.info("dom: ready", {db: db})
})

