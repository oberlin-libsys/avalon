/* 
 * Copyright 2011-2023, The Trustees of Indiana University and Northwestern
 *   University.  Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 * 
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed
 *   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 *   CONDITIONS OF ANY KIND, either express or implied. See the License for the
 *   specific language governing permissions and limitations under the License.
 * ---  END LICENSE_HEADER BLOCK  ---
*/

/**
 * Get new timeline scopes for active section playing
 * @function getTimelineScopes
 * @param title title of the mediaobject
 * @return { [{string, int, string}], string } { [{label, tracks, t}], streamId } = [scope label, number of tracks, mediafragment], masterfile id
 */
function getTimelineScopes(title) {
  let scopes = new Array();
  let trackCount = 1;
  let currentStructureItem = $('li[class="ramp--structured-nav__list-item active"]');
  let activeItem = getActiveItem();
  let streamId = activeItem.streamId;

  scopes.push({
    label: activeItem.label,
    tracks: trackCount,
    times: activeItem.times,
    tag: 'current-track',
  });

  let parent = currentStructureItem.closest('ul').closest('li');
  while (parent.length > 0) {
    let next = parent.closest('ul').closest('li');
    let tracks = parent.find('li a');
    trackCount = tracks.length;
    let begin = parseFloat(tracks[0].hash.split('#t=').reverse()[0].split(',')[0]) || 0;
    let end = parseFloat(tracks[trackCount - 1].hash.split('#t=').reverse()[0].split(',')[1]) || '';
    streamId = tracks[0].pathname.split('/').reverse()[0];
    let label = cleanLabel(
      parent[0].childNodes[0].textContent, 
      parent.find('.ramp--structured-nav__section-duration')
    );
    scopes.push({
      label: next.length == 0 ? `${title} - ${label}` : label,
      tracks: trackCount,
      times: { begin, end },
    });
    parent = next;
  }
  return { scopes: scopes.reverse(), streamId };
}

/**
 * Clean label text from structured navigation
 * @param {String} label full label text of active item
 * @param {Object} timestamp HTML span element with duration for section items
 * @returns {String} label without index numbers and duration information
 */
function cleanLabel(label, timestamp) {
  let labelWoIndex = label.replace(/^[0-9]+./, '');
  if(timestamp?.length > 0) {
    let time = timestamp[0].textContent;
    return labelWoIndex.replace(time, '');
  } else {
    return labelWoIndex.split(' (')[0];
  }
}

/**
 * Parse time in seconds to hh:mm:ss.ms format
 * @param {Number} secTime time in seconds
 * @param {Boolean} showHrs flag indicating for showing hours
 * @returns 
 */
function createTimestamp(secTime, showHrs) {
  let hours = Math.floor(secTime / 3600);
  let minutes = Math.floor((secTime % 3600) / 60);
  let seconds = secTime - minutes * 60 - hours * 3600;
  if (seconds > 59.9) {
    minutes = minutes + 1;
    seconds = 0;
  }
  seconds = parseInt(seconds);

  let hourStr = hours < 10 ? `0${hours}` : `${hours}`;
  let minStr = minutes < 10 ? `0${minutes}` : `${minutes}`;
  let secStr = seconds < 10 ? `0${seconds}` : `${seconds}`;

  let timeStr = `${minStr}:${secStr}`;
  if (showHrs || hours > 0) {
    timeStr = `${hourStr}:${timeStr}`;
  }
  return timeStr;
}

/**
 * Update section and lti section share links and embed code when switching sections
 * @function updateShareLinks
 * @return {void}
 */
function updateShareLinks (e) {
  const sectionShareLink = e.detail.link_back_url;
  const ltiShareLink = e.detail.lti_share_link;
  const embedCode = e.detail.embed_code;
  $('#share-link-section')
    .val(sectionShareLink)
    .attr('placeholder', sectionShareLink);
  $('#ltilink-section')
    .val(ltiShareLink)
    .attr('placeholder', ltiShareLink);
  $('#embed-part').val(embedCode);
}

/** Collapse multi item check for creating a playlist item for each structure item of
 * the selected scope
 */
function collapseMultiItemCheck () {
  $('#multiItemCheck').collapse('show');
  $('#moreDetails').collapse('hide');
}

/** Collapse title and description forms */
function collapseMoreDetails() {
  $('#moreDetails').collapse('show');
  $('#multiItemCheck').collapse('hide');
  let currentTrackName = $('#current-track-name').text();
  $('#playlist_item_title').val(currentTrackName);
}

/** AJAX request for add to playlist for submission for playlist item for 
 * a selected clip
 */
function addPlaylistItem (playlistId, masterfileId) {
  $.ajax({
    url: '/playlists/' + playlistId + '/items',
    type: 'POST',
    data: {
      playlist_item: {
        master_file_id: masterfileId,
        title: $('#playlist_item_title').val(),
        comment: $('#playlist_item_description').val(),
        start_time: $('#playlist_item_start').val(),
        end_time: $('#playlist_item_end').val()
      }
    },
    success: function(res) {
      handleAddSuccess(res);
    },
    error: function(err) {
      handleAddError(err)
    }
  });
}

/** AJAX request for add to playlist for submission for playlist items for 
 * section(s)
 */
function addToPlaylist(playlistId, scope, masterfileId, moId) {
  $.ajax({
    url: '/media_objects/' + moId + '/add_to_playlist',
    type: 'POST',
    data: {
      post: {
        masterfile_id: masterfileId,
        playlist_id: playlistId,
        playlistitem_scope: scope
      }
    },
    success: function(res) {
      handleAddSuccess(res);
    },
    error: function(err) {
      handleAddError(err)
    }
  });
}

/** Show success message for add to playlist */
function handleAddSuccess(response) {
  let alertEl = $('#add_to_playlist_alert');

  alertEl.removeClass('alert-danger');
  alertEl.addClass('alert-success');
  alertEl.find('#add_to_playlist_result_message').html(response.message);

  alertEl.slideDown();
  $('#add_to_playlist_form_group').slideUp();
  resetAddToPlaylistForm();
}

/** Show error message for add to playlist */
function handleAddError(error) {
  let alertEl = $('#add_to_playlist_alert');
  let message = error.statusText || 'There was an error adding to playlist';

  if (error.responseJSON && error.responseJSON.message) {
    message = error.responseJSON.message.join('<br/>');
  }

  alertEl.removeClass('alert-success');
  alertEl.addClass('alert-danger add_to_playlist_alert_error');
  alertEl.find('#add_to_playlist_result_message').html('ERROR: ' + message);

  alertEl.slideDown();
  $('#add_to_playlist_form_group').slideUp();
  resetAddToPlaylistForm();
}

/** Reset add to playlist form */
function resetAddToPlaylistForm() {
  $('#playlist_item_start')[0].value = '';
  $('#playlist_item_end')[0].value = '';
  $('#playlist_item_description').value = '';
  $('#playlist_item_title').value = '';
  $('input[name="post[playlistitem_scope]"]').prop('checked', false);
  $('#playlistitem_scope_structure').prop('checked', false);
  $('#moreDetails').collapse('hide');
  $('#multiItemCheck').collapse('hide');
}

/** Reset add to playlist panel when alert is closed */
function closeAlert() {
  $('#add_to_playlist_alert').slideUp();
  $('#add_to_playlist_form_group').slideDown();
}

/** Get the current active structure item from DOM */
function getActiveItem() {
  let currentPlayer = document.getElementById('iiif-media-player');
  let duration = currentPlayer.player.duration();
  let currentStructureItem = $('li[class="ramp--structured-nav__list-item active"]');
  if(currentStructureItem.find('a').length > 0) {
    let item = currentStructureItem.find('a')[0];
    let label = cleanLabel(item.text, 
      currentStructureItem.find('.ramp--structured-nav__section-duration'));
    let timeHash = item.hash.split('#t=').reverse()[0];
    let times = {
      begin: parseFloat(timeHash.split(',')[0]) || 0,
      end: parseFloat(timeHash.split(',')[1]) || duration
    }
    let streamId = item.pathname.split('/').reverse()[0];
    return { label, times, streamId };
  }
}
