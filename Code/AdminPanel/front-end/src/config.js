let googleMapsKey = process.env.VUE_APP_GOOGLE_MAPS_API_KEY
let apiUrl = process.env.VUE_APP_API_URL
let systemName = process.env.VUE_APP_SYSTEM_NAME
let originLat = process.env.VUE_APP_ORIGIN_LAT
let originLng = process.env.VUE_APP_ORIGIN_LNG
export const Keys = {
    GOOGLE_MAPS_API_KEY: googleMapsKey,
    VUE_APP_API_URL: apiUrl,
    VUE_APP_SYSTEM_NAME: systemName,
    VUE_APP_ORIGIN_LAT: originLat,
    VUE_APP_ORIGIN_LNG: originLng
};
