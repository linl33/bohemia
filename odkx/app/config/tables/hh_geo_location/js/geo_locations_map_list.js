/**
 * This is the file that will be creating the list view.
 */
/* global odkTables, odkData, odkCommon */
/* exported display, handleClick */
'use strict';

var geoResult = {};
var tableId = null;
var hh_id = null;
function handleClick(rowId) {
    odkTables.openDetailView(null,
        tableId,
        rowId,
        'config/tables/hh_geo_location/html/geo_locations_detail.html');
}

function render(result) {
    // The client id should have been passed to us as the hash.
    // var hash = window.location.hash;
    // if (hash === '') {
    //     console.log('The hash containing the client id was not present!');
    //     console.log('Inferring from table');
    //     hh_id = result.get('client_id');
    // } else {
    //     // The has begins a physical hash. Strip it.
    hh_id = hash.substring(1);
    //     console.log('client id is: ' + hh_id);
    // }

    if (hh_id === null || hh_id === '' ||
        hh_id === undefined) {
        return;
    }

    geoResult = result;

    tableId = geoResult.getTableId();

    // Ensure that this is the first displayed in the list
    var mapIndex = geoResult.getMapIndex();
    
    // Make sure that it is valid
    if (mapIndex !== null && mapIndex !== undefined) {
        // Make sure that it is not invalid 
        if (mapIndex !== -1) {
            // Make this the first item in the list
            addDataForRow(mapIndex);
        }
    }

    for (var i = 0; i < geoResult.getCount(); i++) {
        // Make sure not to repeat the selected item if one existed
        if (i === mapIndex) {
            continue;
        }

        addDataForRow(i);
    }
}

function addDataForRow(rowNumber) {
    // Creating the item space
    var item = document.createElement('li');
    item.setAttribute('class', 'item_space');
    item.setAttribute(
        'onClick',
        'handleClick("' + geoResult.getRowId(rowNumber) + '")');
    item.innerHTML = hh_id;
    document.getElementById('list').appendChild(item);

    var chevron = document.createElement('img');
    chevron.setAttribute(
        'src',
        odkCommon.getFileAsUrl('config/assets/img/little_arrow.png'));
    chevron.setAttribute('class', 'chevron');
    item.appendChild(chevron);

}

function cbFailure(error) {
    console.log('geo_locations_map_list: cbFailure failed with error: ' + error);
}


function display() {
    odkData.getViewData(render, cbFailure);
}