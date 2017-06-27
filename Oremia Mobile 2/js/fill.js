var fbTemplate = document.getElementById('fb-template'),
    formContainer = document.getElementById('rendered-form'),
    $fBInstance,
    formRenderOpts,
    idDocument,
    idPatient,
    idPrat,
    date = new Date(),
    datadoc,
    dbname = getUrlParameter("db"),
    user = getUrlParameter("login"),
    pw = getUrlParameter("pw"),
    signaturePad;
    
    
$(document).ready(function($) {
    $fBInstance = $(document.getElementById('edit-form'))
    var canvas = document.querySelector("canvas");
    signaturePad = new SignaturePad(canvas);
    formRenderOpts = {
      container: $('form', formContainer)
    };
    idDocument = getUrlParameter("idDocument");
    idPatient = getUrlParameter("idPatient");
    idPrat = getUrlParameter("idPrat");
    if (idDocument && idPatient) {
        query="SELECT idtype, nomtype, nomfichier FROM typedocument WHERE idtype ="+idDocument+";";
        selectQuery(query,function(data){
            if (data.results[0].nomfichier == "questionnaire medical" && data.results[0].nomtype == "questionnaire medical") {
                $("#title").html(data.results[0].nomtype);
                performUpdateFirstDoc();
            }else{
                $("#fb-template").html(decodeEntities(data.results[0].nomfichier));
                $("#title").html(data.results[0].nomtype);
                loadForm();
            }

        })
    }else{
        query="SELECT * FROM modele_document WHERE iddocument ="+idDocument+";";
        selectQuery(query,function(data){
            datadoc = data.results[0].datadoc;
            idPrat = data.results[0].idprat;
            idPatient = data.results[0].idpatient;
            query="SELECT nomtype, nomfichier FROM typedocument WHERE idtype ="+data.results[0].idtype+";";
            selectQuery(query,function(data){
                $("#fb-template").html(decodeEntities(data.results[0].nomfichier));
                //$("#title").html(data.results[0].nomtype);
                loadForm();
            })
        })
    }

});
function loadForm(){
    $(fbTemplate).formRender(formRenderOpts);
    $(fbTemplate).remove();
    wrapAll();
    $(".form-builder").toggle();
    if(datadoc){
        $('#rendered-form form').unserializeForm(datadoc);
    }
    $("#clearSignature").click(function(){
        signaturePad.clear();
    })
    $('#sendForm').click(function() {        
        var serializedForm = $('#rendered-form form').serialize();
        
        var formData = $('#rendered-form form').serializeObject();
        $.extend(formData, getLabelFromForm("#rendered-form form"));
        $.extend(formData, {"signature" : signaturePad.toDataURL()});
        if(datadoc){
            query = "UPDATE modele_document SET datadoc = '"+serializedForm+"' WHERE iddocument ="+idDocument+";";
        }else{
            query = "INSERT INTO modele_document(idprat, idpatient, datadoc, idtype, date) VALUES ("+idPrat+", "+idPatient+", '"+serializedForm+"', "+idDocument+", '"+date.yyyymmdd()+"');";
        }
        console.log(query);
        insertQuery(query, function(data){
            if(data.match(/1/i)){
                notifySucceed("Mise à jour réussie.", "Votre questionnaire a été mis à jour");
            }else{
                notifyFail("Mise à jour échouée.", "Votre questionnaire n'a pas été mis à jour <br><strong>Veuillez réessayer de sauvegarder.</strong>");
            }
        }, formData)
    });

    $('.edit-form', formContainer).click(function() {
        $fBInstance.toggle();
        $(formContainer).toggle();
    });
}

function selectQuery(query, success){
    vdata={"dbname":dbname, "user":user, "pw":pw, "query": query};
    $.ajax({
        type: "POST",
        url: 'http://192.168.0.15/scripts/OremiaMobileHD/index.php?type=11',
        contentType: "application/x-www-form-urlencoded;charset=ISO-8859-15",
        data: vdata,
        dataType:"json"
    }).done(function( data ){
        success(data);
    });
}
function insertQuery(query, success, extension){
    vdata={"connect" : {"dbname":dbname, "user":user, "pw":pw,"nomfichier":"Doc1","file":"", "query": query, "idPraticien": idPrat, "idPatient" : idPatient}};
    if(extension){
        $.extend(vdata, extension);
    }
    $.ajax({
      type: "POST",
      url: 'http://192.168.0.15/scripts/OremiaMobileHD/index.php?type=9',
      contentType: "application/x-www-form-urlencoded;charset=ISO-8859-15",
      data: vdata
    }).done(function(data){
        success(data);
    });
}

function notifySucceed(title, message){
    $("body").append('<div class="alert alert-success" role="alert">'+title+'<br>'+message+'</div>')
    setTimeout(function(){ $(".alert").remove() }, 3000);
}
function notifyFail(title, message){
    $("body").append('<div class="alert alert-danger" role="alert">'+title+'<br>'+message+'</div>')
    setTimeout(function(){ $(".alert").remove() }, 3000);
}
function decodeEntities(encodedString) {
    var textArea = document.createElement('textarea');
    textArea.innerHTML = encodedString;
    return textArea.value;
}
function encodeEntities(str){
    return str.replace(/[\u00E0-\u00FC]/gim, function(i) {
       return '&#'+i.charCodeAt(0)+';';
    });
}

function performUpdateFirstDoc(){
    $.ajax({
        type: "GET",
        url: 'http://rdelaporte.alwaysdata.net/OM/questionnaire/',
        contentType: "application/x-www-form-urlencoded;charset=ISO-8859-15",
        data: vdata,
        dataType:"text"
    }).done(function( data ){
            $("#fb-template").html(decodeEntities(data));
            loadForm();
            query = "UPDATE typedocument SET nomfichier = '"+data+"' WHERE idtype = 1;"
            insertQuery(query, function(data){

        })
    });
}

function getUrlParameter(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    };
Date.prototype.yyyymmdd = function() {
  var mm = this.getMonth() + 1; // getMonth() is zero-based
  var dd = this.getDate();

  return [this.getFullYear(), mm, dd].join('-'); // padding
};

