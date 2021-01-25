/**
 * The file for displaying a detail view.
 */
/* global odkData */
/*exported display */
'use strict';

function cbSuccess(result) {
    var hh_id = result.get('hh_id');
    document.getElementById('title').innerHTML = hh_id;

    // display location geo points
    var latitude = result.get('coordinates.latitude');
    var longitude = result.get('coordinates.longitude');
    if (latitude !== null && latitude !== undefined && longitude !== null && longitude !== undefined) {
        document.getElementById('coordinates').innerHTML = latitude + 
        ' ' + longitude;
    }
}

function cbFailure(error) {
    console.log('geo_locations_detail: failed with error: ' + error);
}

function display() {
    odkData.getViewData(cbSuccess, cbFailure);
}