/**
 * This is the file that will be creating the list view.
 */
/* global $, odkTables, odkData, odkCommon */
'use strict';

var hh_geo_location = {};

function handleClick(rowId) {
    if (!$.isEmptyObject(hh_geo_location)) {
        odkTables.openDetailView(
			null,
            hh_geo_location.getTableId(),
            rowId,
            'config/tables/hh_geo_location/html/geo_locations_detail.html');
    }
}

function render(result) {
    hh_geo_location = result;
    console.log('The number of results is ' + result.getCount());

    // The client id should have been passed to us as the hash.
    // var hash = window.location.hash;
    // console.log('window.location.href is: ' + window.location.href);
    // var clientId = null;
    // if (hash === '') {
    //     console.log('The hash containing the client id was not present!');
    //     console.log('Inferring client id');
    hh_id = result.get(0).toUpperCase();
    // } else {
    //     // The hash begins with a physical hash. Strip it.
    //     clientId = hash.substring(1);
    //     console.log('client id is: ' + clientId);
    // }

    /* Create item to launch map view display */
    var mapView = document.createElement('p');
    mapView.setAttribute('class', 'launchForm');
    mapView.innerHTML = 'Map View';
    mapView.onclick = function() {
        odkTables.openTableToMapView(
				null,
                'hh_geo_location',
                'hh_id = ?',
                [hh_id],
                null);
    };
    document.getElementById('header').appendChild(mapView);

    /* Create item to launch geo point form */
    // var waypoint = document.createElement('p');
    // waypoint.setAttribute('class', 'launchForm');
    // var elementKeyToValueMap = {};
    // // Prepopulate client id
    // elementKeyToValueMap.client_id = clientId;
    // // Add step every time you launch waypoint form.
    // elementKeyToValueMap.step = result.getCount() + 1;

    // waypoint.onclick = function() {
    //     odkTables.addRowWithSurvey(
	// 			null,
    //             'geopoints',
    //             'geopoints',
    //             null,
    //             elementKeyToValueMap);
    // };
    // waypoint.innerHTML = 'Add Waypoint';
    // document.getElementById('header').appendChild(waypoint);

    for (var i = 0; i < result.getCount(); i++) {

        /*    Make list entry only if household id exists */
        if(hh_id !== null && hh_id !== '') {
            /*    Creating the item space    */
            var item = document.createElement('li');
            item.setAttribute('class', 'item_space');
            item.setAttribute(
                'onClick',
                'handleClick("' + result.getRowId(i) + '")');
            item.innerHTML = hh_id;
            document.getElementById('list').appendChild(item);

            var chevron = document.createElement('img');
            chevron.setAttribute(
                'src',
                odkCommon.getFileAsUrl('config/assets/img/little_arrow.png'));
            chevron.setAttribute('class', 'chevron');
            item.appendChild(chevron);

        }
    }
}

function cbFailure(error) {
    console.log('geo_locations_list: cbFailure failed with error: ' + error);
}

function display() {
    odkData.getViewData(render, cbFailure);
}