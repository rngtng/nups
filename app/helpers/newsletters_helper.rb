module NewslettersHelper
  def periodically_call_remote(options = {})
     frequency = options[:frequency] || 10 # every ten seconds by default
     repeat = options[:repeat] || 'true' # every ten seconds by default
     code = <<-JAVASCRIPT 
jQuery.fjTimer({
  interval: #{frequency},
  repeat: #{repeat},
  tick: function(counter, timerId) {
    jQuery.ajax({
        url: '#{options[:url]}',
        type: '#{options[:method].to_s.upcase}',
        beforeSend: function (xhr) {
            //el.trigger('ajax:loading', xhr);
        },
        success: function (data, status, xhr) {
            $('#{options[:replace]}').replaceWith(data);
        },
        complete: function (xhr) {
            //el.trigger('ajax:complete', xhr);
        },
        error: function (xhr, status, error) {
            //el.trigger('ajax:failure', [xhr, status, error]);
        }
    });
 }
});
JAVASCRIPT
     javascript_tag(code)
  end
  
    def delayed_remote_function(options = {})
       delay = options[:delay] || 3000
       fnc_name = 'request12' #options[:replace]
       code = <<-JAVASCRIPT 
  JAVASCRIPT
       javascript_tag(code)
    end  
end


