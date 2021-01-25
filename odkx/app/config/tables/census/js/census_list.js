/**
 * This is the file that will be creating the list view.
 */
/* global $, odkTables, odkData, odkCommon */
/*exported display, handleClick, getResults */
'use strict';

var census = {};

/** Handles clicking on a list item. Applied via a string. */
function handleClick(index) {
    if (!$.isEmptyObject(census)) {
        odkTables.openDetailView(null,
            census.getTableId(),
            index,
            'config/tables/census/html/census_detail.html');
    }

}

function cbSRSuccess(searchData) {
    console.log('cbSRSuccess data is' + searchData);
    if(searchData.getCount() > 0) {
        // open filtered list view if househild found
        var rowId = searchData.getRowId(0);
        odkTables.openTableToListView(null,
                'census',
                '_id = ?',
                [rowId],
                'config/tables/census/html/census_list.html');
    } else {
        document.getElementById("search").value = "";
        document.getElementsByName("query")[0].placeholder="Household not found";
    }
}

function cbSRFailure(error) {
    console.log('census_list: cbSRFailure failed with error: ' + error);
}

// filters list view by client id entered by user
function getResults() {
    var searchText = document.getElementById('search').value;

    odkData.query('census', 'hh_id = ?', [searchText], 
        null, null, null, null, null, null, true, cbSRSuccess, cbSRFailure);
}

// displays list view of clients
function render() {

    /* create button that launches graph display */
    var graphView = document.createElement('p');
    graphView.onclick = function() {
        odkTables.openTableToListView(null,
                'census',
                null,
                null,
                'config/tables/census/html/graph_view.html');
    };
    graphView.setAttribute('class', 'launchForm');
    graphView.innerHTML = 'Graph View';
    document.getElementById('searchBox').appendChild(graphView);

    for (var i = 0; i < census.getCount(); i++) {

        var hh_id = census.getData(i, 'hh_id');

        // make list entry only if household id exists
        if (hh_id !== null &&
            hh_id !== '' 
            ) {
            /*    Creating the item space    */
            var item = document.createElement('li');
            item.setAttribute('class', 'item_space');
            item.setAttribute(
                    'onClick',
                    'handleClick("' + census.getRowId(i) + '")');
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

function cbSuccess(result) {
    census = result;
    render();
}

function cbFailure(error) {
    console.log('census_list: failed with error: ' + error);
}

function display() {
    odkData.getViewData(cbSuccess, cbFailure);
}