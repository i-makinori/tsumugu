/* utils */

function matrix( rows, cols, defaultValue){
  // https://stackoverflow.com/questions/966225/how-can-i-create-a-two-dimensional-array-in-javascript#answer-18116922
  var arr = [];
  for(var i=0; i < rows; i++){
      arr.push([]);
      arr[i].push( new Array(cols));
      for(var j=0; j < cols; j++){
        arr[i][j] = defaultValue;
      }
  }
  return arr;
}


function id_dot(id_name){
  return document.getElementById(id_name);
}

/* I/O */


function dot_height(){
  return id_dot("height").value;
}

function dot_width(){
  return id_dot("width").value;
}

function getval(cel) {
  alert(cel.innerHTML);  
}

function update_conway_table(field_array){
  var table_element = id_dot("conway_table");
  var tml_buffer = [];
  var alter_cell_func = "alter_cell_state";
  
  for(var y=0; y<field_array.length; y++){
    tml_buffer.push("<tr>");
    for(var x=0; x<field_array[y].length; x++){
      tml_buffer.push("<td onclick=\""+alter_cell_func+"("+y+","+x+")\">");
      tml_buffer.push(show_cell(field_array[y][x])+"</td>");
    }
    tml_buffer.push("</tr>");
  }
  table_element.innerHTML = tml_buffer.join('');
}


/* params */

live=1; 
dead=0;

function show_cell(condition){
  return condition?'#':'_';
}


function sum_living(cell_array){
  sum = cell_array.reduce((sum, current) => sum+current, 0)
  return sum
}


function update_cell_conway(nn, nc, np,   cn, cc, cp,   pn, pc, pp){
  // ** : {delta_y}{delta_x}
  // delta_x or delta_y = n::negative:-1 | c::current:0 | p::positive:+1

  is_living = cc;
  neighbor_livs = sum_living([nn, nc, np, cn, cp, pn, pc, pp]);

  var cell_next = dead;
  if(is_living&&(neighbor_livs==2||neighbor_livs==3)){
    cell_next = live;
  } else if(!is_living&&neighbor_livs==3){
    cell_next = live;
  } else {
    cell_next = dead;
  }

  return cell_next;
}

/* statement */

var the_world = {
  height: 0,
  width: 0,
  generation: 0,
  update_cell: update_cell_conway,
  field: [[]],
};


/* game loop */

function whileSleep(_condition,_interval, _mainFunc){
  // https://qiita.com/akyao/items/a718cc78436df68d7e15
  var condition = _condition;
  var interval = _interval;
  var mainFunc = _mainFunc;
  var i = 0;
  var loopFunc = function() {
    i = i+1;
    mainFunc(i);
    if (condition.apply(i)) {
      setTimeout(loopFunc, interval);
    }
  }
  loopFunc();
}

function loopSleep(_condition,_interval, _mainFunc){
  // https://qiita.com/akyao/items/a718cc78436df68d7e15
  var condition = _condition;
  var interval = _interval;
  var mainFunc = _mainFunc;
  var i = 0;
  var loopFunc = function() {
    if(condition(i)){
      i=i+1;
      mainFunc(i);
    }
    setTimeout(loopFunc, interval(i));
  }
  loopFunc();
}

function repl(world){
  the_world;
  loopSleep(
    function(i){ return time_move() },
    function(i){ return 100},
    function(i){ 
      console.log(i);
      next_world(the_world);
      update_conway_table(the_world.field);
    }
  );   
}

/* update */

function next_world(before_world){
  the_world.field = next_field(before_world);
  return the_world;
}

function next_field(before_world){
  wid = before_world.width;
  hei = before_world.height;
  update_func = before_world.update_cell;

  befo = before_world.field;
  next = matrix(hei, wid, dead);

  var y_edgi = function(y){
    return y>=hei?0:y<0?hei-1:y;
  }
  var x_edgi = function(x){
    return x>=wid?0:x<0?wid-1:x;
  }
    
  // _n::negative:-1, _c=current:0, _p:positive:+1
  for(y=0; y<hei; y++){
    y_n=y_edgi(y-1); y_c=y_edgi(y); y_p=y_edgi(y+1);

    for(x=0; x<wid; x++){
      x_n=x_edgi(x-1); x_c=x_edgi(x); x_p=x_edgi(x+1);

      next[y][x] = update_func(
        befo[y_n][x_n], befo[y_n][x_c], befo[y_n][x_p],
        befo[y_c][x_n], befo[y_c][x_c], befo[y_c][x_p],
        befo[y_p][x_n], befo[y_p][x_c], befo[y_p][x_p]
      )
    }
  }

  return next;
}


/* time */

var time_moving=function(){};

function time_next(){
  // ((fai)) => (fai)
  time_moving = function(){return time_moving = time_stop};
}

function time_pass(){
  // (t) => (t)
  time_moving = function(){return time_pass};
}
  
function time_stop(){
  // (fai) => (fai)
  time_moving = function(){return false};
}

function time_move(){
  // console.log(time_moving);
  return time_moving.apply();
}


/* init */

function reset_the_world(){

  the_world.height = dot_height();
  the_world.width = dot_width();
  the_world.field = init_field_array(the_world.height, the_world.width);

  update_conway_table(the_world.field);
  
  repl(the_world);
}


function init_field_array(height, width){
  var field = matrix(height, width, dead);
  return field;
}

/* field */

function show_field(field_array){
  for(var y=0; y<field_array.length; y++){
    console.log(y+": "+field_array[y].join(""));
  }
}

function alter_cell_state(y, x){
  the_world.field[y][x] = (the_world.field[y][x]==live)?dead:live;
  update_conway_table(the_world.field);
  return the_world.field[y][x];
}