jQuery ->
  toggleInput = ->
    link = $(this)
    link.parent().find('a.edit-line-item').toggle()
    link.parent().find('a.cancel-line-item').toggle()
    link.parent().find('a.save-line-item').toggle();
    link.parents('tr').find('td.item-qty-show').toggle();
    link.parents('tr').find('td.item-qty-edit').toggle();

    false

  ($ '.cancel-line-item').click toggleInput
  ($ '.edit-line-item').click toggleInput

  ($ '.save-line-item').click ->
    quantity = parseInt(($ this).parents('tr').find('input.line_item_quantity').val())

    $.ajax
      type: "PUT",
      url: ($ this).attr("href"),
      data: { line_item: { quantity: quantity } }
      success: (result) ->
        window.location.reload()

    false

  ($ '.delete-line-item').click ->
    if confirm("Are you sure?")
      quantity = parseInt(($ this).parents('tr').find('input.line_item_quantity').val())

      $.ajax
        type: "DELETE",
        url: ($ this).attr("href"),
        success: (result) ->
          window.location.reload()

    false
