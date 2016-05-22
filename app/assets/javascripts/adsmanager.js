//= require jquery
//= require jquery_ujs
//= require parsley
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
//= require core/source/AppCard
//= require core/source/AppNavSearch
//= require core/source/AppVendor
//= require core/demo/Demo
//= require libs/DataTables/jquery.dataTables.min
//= require libs/DataTables/extensions/ColVis/js/dataTables.colVis.min
//= require libs/DataTables/extensions/TableTools/js/dataTables.tableTools.min
//= require libs/bootstrap-datepicker/bootstrap-datepicker
//= require libs/select2/select2.min

// =================================
// COMMON JS
// =================================

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

// =================================
// CAMPAIGNS VIEW
// =================================

$(function(){
  // init datatable
  $('#campains-table, #adgroups-table, #ads-table, #keywords-table').DataTable({
    columnDefs: [{ targets: 'no-sort', orderable: false }],
    "dom": 'lCfrtip',
    "order": [],
    "colVis": {
      "buttonText": "Columns",
      "overlayFade": 0,
      "align": "right"
    },
    "language": {
      "lengthMenu": '_MENU_ entries per page',
      "search": '<i class="fa fa-search"></i>',
      "paginate": {
        "previous": '<i class="fa fa-angle-left"></i>',
        "next": '<i class="fa fa-angle-right"></i>'
      }
    }
  });

  // init select2 for account selector
  $('#selected_account_ids').select2();

  // init datepicker
  $('.datepicker').datepicker({
    format: 'yyyy-mm-dd',
    todayBtn: true,
    autoclose: true,
    todayHighlight: true
  });

  // toggle show the start_date and end_date input
  toggleShow();
  $('#date_range_type').change(toggleShow());

  // current tab's index in campaign's detail
  $('.nav-tabs li').click(function(){
    $('#tab_index').val($('.nav-tabs li').index($(this)));
  });
});

function toggleShow() {
  if($('#date_range_type').val() == 'CUSTOM_DATE'){
    $('#custom_start_date_group, #custom_end_date_group').show();
  }
  else{
    $('#custom_start_date_group, #custom_end_date_group').hide();
  }
}
