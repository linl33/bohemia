/**
 * The file for displaying a detail view.
 */
/* global $, odkTables, odkData */
'use strict';

var hh_id;

function createFormLauncherForEdit(tableId, formId, rowId, label, element) {
    var formLauncher = document.createElement('p');
    formLauncher.setAttribute('class', 'forms');
    formLauncher.innerHTML = label;
    formLauncher.onclick = function() {
        odkTables.editRowWithSurvey(
				null,
                tableId,
                rowId,
                formId,
                null);
    };
    element.appendChild(formLauncher);
}

function createFormLauncherForAdd(tableId, formId, elementKeyToValueMap, label, element) {
    var formLauncher = document.createElement('p');
    formLauncher.setAttribute('class', 'forms');
    formLauncher.innerHTML = label;
    formLauncher.onclick = function() {
        odkTables.addRowWithSurvey(
				null,
                tableId,
                formId,
                null,
                elementKeyToValueMap);
    };
    element.appendChild(formLauncher);
}

// Displays details about client and links to various forms
function display(result) {

    // Details - Household id
    hh_id = result.get('hh_id');
    document.getElementById('title').innerHTML = hh_id;

    // Creates key-to-value map that can be interpreted by the specified
    // Collect form - to prepopulate forms with household id
    var elementKeyToValueMapMemberID = {hh_id: hh_id};

    // Create item that displays links to all census forms when clicked
    var fItem = document.createElement('p');
    fItem.innerHTML = 'Census Forms';
    fItem.setAttribute('class', 'heading');

    var fContainer = document.createElement('div');
    fContainer.setAttribute('class', 'detail_container');

    var homeLocator = document.createElement('p');
    homeLocator.setAttribute('class', 'forms');
    homeLocator.innerHTML = 'Home Locator';
    // When we open the geopoints file, we want to communicate the client id so
    // that the file will know whose data it is displaying. We're going to do
    // this using a hash.
    // console.log('in this particularly XXXXXXXXX file!');
    // $(homeLocator).click(function() {
    //     console.log('In homeLocator click hh_id is ' + hh_id);
    //     odkTables.openTableToListView(
	// 		null,
    //         'geopoints',
    //         'hh_id = ?',
    //         ['' + hh_id],
    //         'config/tables/geopoints/html/geopoints_list.html#' + hh_id);
    // });
    // fContainer.appendChild(homeLocator);

    var rowId = result.getRowId(0);
    console.log('rowId: ' + rowId);
    createFormLauncherForEdit(
            'census',
            'census',
            rowId,
            'Census Info Update',
            fContainer);
    createFormLauncherForEdit(
            'hh_member',
            'hh_member',
            rowId,
            'Household Member Info Update',
            fContainer);

    $(fContainer).hide();
    $(fItem).click(function() {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            $(this).addClass('selected');
        }
        $(this).next(fContainer).slideToggle('slow');
    });

    // Create item that displays links to all member forms when clicked
    var mItem = document.createElement('p');
    mItem.innerHTML = 'Repeat Forms';
    mItem.setAttribute('class', 'heading');

    var mContainer = document.createElement('div');
    mContainer.setAttribute('class', 'detail_container');
    createFormLauncherForAdd(
            'hh_member',
            'hh_member',
            elementKeyToValueMapMemberID,
            'Members in Household',
            mContainer);
    // TODO: this should be passing the rowId of the entry in the client table,
    // as filtered by the hh_id.
    createFormLauncherForEdit(
            'hh_member',
            'hh_member_questions',
            hh_id,
            'Member Individual Questionnaire',
            mContainer);

    $(mContainer).hide();
    $(mItem).click(function() {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            $(this).addClass('selected');
        }
        $(this).next(mContainer).slideToggle('slow');
    });

    document.getElementById('wrapper').appendChild(fItem);
    document.getElementById('wrapper').appendChild(fContainer);

    document.getElementById('wrapper').appendChild(mItem);
    document.getElementById('wrapper').appendChild(mContainer);

}

function cbSuccess(result) {
    display(result);
}

function cbFailure(error) {
    console.log('census detail: failed with error: ' + error);
}

// handles events from html page
function setup() {
    odkData.getViewData(cbSuccess, cbFailure);
}

$(document).ready(setup);
