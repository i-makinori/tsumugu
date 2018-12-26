
// buffer

function openBuffer(evt, buffer_name) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("editor_content");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(buffer_name).style.display = "block";
  evt.currentTarget.className += " active";
}


function openBufferAll(evt) {
  var i;
  tabcontent = document.getElementsByClassName("editor_content");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "block"
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
}

// edit-parameters



// markdown

function parse_markdown(){
  document.getElementById('editor_preview_markdown_preview').innerHTML =
  marked(document.getElementById('editor_markdown_markdown').value);
}

parse_markdown();