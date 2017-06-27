var vretour = {},
form;

function getLabelFromForm(form){
	form = form;
	var formData = $('#rendered-form form').serializeArray();
	formData.forEach(appendArrayElements);
	return vretour;
}

function appendArrayElements(element) {
	vretour["question-"+element.name] = $("label[for="+element.name.replace("[]","")+"]").html();
}

$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};