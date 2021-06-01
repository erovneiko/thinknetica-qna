$(document).on('turbolinks:load', loadGists);

function loadGists() {
  $('.gist').each(loadGist);
}

function loadGist() {
  let callbackName = 'c' + Math.random().toString(36).substring(7);
  let gistElement = $(this);

  window[callbackName] = function (gistData) {
    delete window[callbackName];
    gistElement.html(
      `<link rel="stylesheet" href="${ encodeURI(gistData.stylesheet) }"></link>\n` +
      `${ gistData.div }`
    );
  };

  let script = document.createElement('script');
  let src = [$(this).data('src'), $.param({callback: callbackName})].join('?');

  script.setAttribute('src', src);
  gistElement.append(script);
}
