// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require nprogress
//= require bootstrap-sprockets
//= require libs/spin.js/spin.min
//= retuire libs/autosize/jquery.autosize.min
//= require libs/moment/moment.min
//= require libs/flot/jquery.flot.min
//= require libs/flot/jquery.flot.time.min
//= require libs/flot/jquery.flot.resize.min
//= require libs/flot/jquery.flot.orderBars
//= require libs/flot/jquery.flot.pie
//= require libs/flot/curvedLines
//= require libs/jquery-knob/jquery.knob.min
//= require libs/sparkline/jquery.sparkline.min
//= require libs/nanoscroller/jquery.nanoscroller.min
//= require libs/d3/d3.min
//= require libs/d3/d3.v3
//= require libs/rickshaw/rickshaw
//= require core/source/App
//= require core/source/AppNavigation
//= require core/source/AppOffcanvas
//= require core/source/AppCard
//= require core/source/AppForm
//= require core/source/AppNavSearch
//= require core/source/AppVendor
//= require core/demo/Demo
//= require libs/DataTables/jquery.dataTables.min
//= require libs/DataTables/extensions/ColVis/js/dataTables.colVis.min
//= require libs/DataTables/extensions/TableTools/js/dataTables.tableTools.min

// init progress bar
NProgress.configure({
  showSpinner: false,
  ease: 'ease',
  speed: 500
});

window.onbeforeunload = function(e) {
  NProgress.start();  
};

$(function(){
  // set timeout for alert close
  window.setTimeout(function() { $(".message").alert('close'); }, 5000);

  // done progress bar when page loaded
  NProgress.set(0.2);
  NProgress.done();
});
