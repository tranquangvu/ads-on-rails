$("#date_time_zone").empty().append("<%= escape_javascript(render(:partial => @time_zones)) %>");
