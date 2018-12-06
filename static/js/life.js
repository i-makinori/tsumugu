/* utils */

function matrix(rows, cols, defaultValue){
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

function dot_update_par_ms(){
  return id_dot("update_par_ms").value;
}

function write_generation(gene){
  return id_dot("generation").value=gene;
}

function write_current_world(current){
  return id_dot("current_world").value=current;
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
  update_cell: function(){},
  field: [[]],
  the_end_of_the_world: function(){return true}
};

current_world = 0;


/* game loop */

function loopSleep(_when_stop, _condition,_interval, _mainFunc){
  // https://qiita.com/akyao/items/a718cc78436df68d7e15
  var when_stop = _when_stop;
  var condition = _condition;
  var interval = _interval;
  var mainFunc = _mainFunc;
  var i = 0;

  var loopFunc = function() {
    if(condition(i)){
      if(when_stop()){
        return true; 
      }
      i=i+1;
      mainFunc(i);
    }
    setTimeout(loopFunc, interval(i));
  }
  loopFunc();
}

function repl(){
  reset_the_world();
  loopSleep(the_world.the_end_of_the_world, time_move, dot_update_par_ms,
    function(i){ 
      the_world = update_environment(i, the_world, null);
    }
  );
}

/* update */

function update_environment(i ,world, field){
  // read env
  null;
  // data
  var _next_world = next_world(world);
  // write to env
  update_conway_table(world.field);
  write_generation(world.generation);
  // to nexts
  return _next_world;
}

function next_world(before_world){
  var next_world = {
    height: before_world.height,
    width: before_world.width,
    generation: before_world.generation+1,
    update_cell: before_world.update_cell,
    field: next_field(before_world),
    the_end_of_the_world: before_world.the_end_of_the_world
  };
  // the_world = next_world;
  return next_world;
}

function next_field(before_world){
  width = before_world.width;
  height = before_world.height;
  update_func = before_world.update_cell;

  befo = before_world.field;
  next = matrix(height, width, dead);

  var y_edgi = function(y){
    return y>=height?0:y<0?height-1:y;
  }
  var x_edgi = function(x){
    return x>=width?0:x<0?width-1:x;
  }
  
  // _n::negative:-1, _c=current:0, _p:positive:+1
  for(y=0; y<height; y++){
    y_n=y_edgi(y-1); y_c=y_edgi(y); y_p=y_edgi(y+1);

    for(x=0; x<width; x++){
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

var time_moving = function(){};

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

var time_the_end = false;

function time_the_end(){
  time_the_end = true;
}

function time_the_start(){
  time_the_end = false;
}

/* init */

function reset_the_world(){
  height = dot_height();
  width = dot_width();

  current_world = current_world+1;
  let num_current_world = current_world;

  var world = {
    height: height,
    width: width,
    generation: 0,
    field: init_field_array(height, width),
    update_cell: update_cell_conway,
    the_end_of_the_world: function(){
      //console.log(current_world, num_current_world);
      return current_world!=num_current_world;
    }
  }

  the_world=world;

  write_current_world(current_world)

  update_conway_table(world.field);
  
  //repl(world);
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