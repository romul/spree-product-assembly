/*!
 * Spree Product Assembly
 * https://github.com/spree/spree-product-assembly
 *
 */

$("#searchtext").keypress(function (e) {
  if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
    search_for_parts();
    return false;
  } else {
     return true;
  }
});

$("#searchtext").delayedObserver(function(element, value) {
  search_for_parts();
}, 0.75);

function subscribe_product_part_links()
{
  $("a.set_count_admin_product_part_link").click(function(){
    params = { count :  $("input", $(this).parent().parent()).val() };
    return make_post_request($(this), params);
  });
  
  $("a.remove_admin_product_part_link").click(function(){
    return make_post_request($(this), {});
  });
}

function make_post_request(link, post_params)
{
  spinner = $("img.spinner", link.parent())
  spinner.show();
  $.post(link.attr("href"), post_params,
    function (data, textStatus) { spinner.hide(); },
    "script");

  return false;
}

subscribe_product_part_links();
