function wrapAll(){
	$(".container").show();
	$( "form" ).wrapInner( "<fieldset></fieldset>");
	$("h1").addClass("form-title-row");
	$('.form-group > label').each(function(){
		var next = $(this).next('input');
		if (next.attr("type") == "text") {
			$(this).addClass("form-text-label");
			$(this).parent().addClass("form-row form-text-row");
			next.addClass("form-text-input");
			next.andSelf().wrapAll('<fieldset ></fieldset>');
		};
		if($(this).next(".checkbox-group").length > 0){
			$(this).addClass('form-title');
		}
		if($(this).next(".radio-group").length > 0){
			$(this).addClass('form-title');
		}
		if($(this).next("textarea").length > 0){
			$(this).addClass('form-title');
			$(this).next("textarea").addClass("form-text-textarea");
			$(this).next("textarea").attr("placeholder", $(this).html());
			$(this).hide();
			$(this).next("textarea").andSelf().wrapAll('<label class="form-row form-text-row"></label>');
		}
		
	});

	$(".form-group > .checkbox-group").wrapInner("<fieldset></fieldset>");
	$('.checkbox-group > fieldset > input').each(function(){
		var next = $(this).next('label');
		next.addClass("form-option-label");
		$(this).addClass("form-option-input");
		next.andSelf().wrapAll('<label class="form-row form-option-row"></label>');
	});
	$('.checkbox-group > fieldset br').remove();

	$(".form-group > .radio-group").wrapInner("<fieldset></fieldset>");
	$('.radio-group > fieldset > input').each(function(){
		var next = $(this).next('label');
		next.addClass("form-option-label");
		$(this).addClass("form-option-input");
		next.andSelf().wrapAll('<label class="form-row form-option-row"></label>');
	});
	$('.radio-group > fieldset br').remove(); 
}