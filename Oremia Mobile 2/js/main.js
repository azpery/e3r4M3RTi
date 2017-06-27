var fbTemplate = document.getElementById('fb-template'),
    formContainer = document.getElementById('rendered-form'),
    $fBInstance,
    formRenderOpts,
    idDocument,
    dbname = getUrlParameter("db"),
    user = getUrlParameter("login"),
    pw = getUrlParameter("pw");
    
    
$(document).ready(function($) {
    $fBInstance = $(document.getElementById('edit-form'))
    formRenderOpts = {
      container: $('form', formContainer)
    };
    idDocument = getUrlParameter("idDocument");
    loadExistingDocuments();
    init()
    handleAdd()
});

$(window).resize(function($) {
    fit();
});

function init(){
    if (idDocument) {
        query="SELECT nomfichier FROM typedocument WHERE idtype ="+idDocument+";";
        selectQuery(query,function(data){
            $("#fb-template").html(decodeEntities(data.results[0].nomfichier));
            loadForm();
        })
    }else{
        loadForm();
    }
}
function loadForm(){
    $(".docSelection li").removeClass("selected");
    $("#"+idDocument+"").addClass("selected");
    var formBuilder = $(document.getElementById('fb-template')).formBuilder({messages: language,disableFields: ['autocomplete', 'hidden', 'paragraph', 'file', 'select', 'button']});
    $( ".form-builder-save").unbind( "click" );
    //$(formContainer).toggle();
    $('.form-builder-save').click(function(e) {
        e.preventDefault()
        var formData = encodeEntities(typeof formBuilder.data('formBuilder').formData == "string" ? formBuilder.data('formBuilder').formData : xmlToString(formBuilder.data('formBuilder').formData));
        if(idDocument){
            query = "UPDATE typedocument SET nomfichier = '"+formData+"' WHERE idtype = "+idDocument+";";
        }else{
            query = "INSERT INTO typedocument(idtype, nomtype, nomfichier) VALUES (DEFAULT, 'Doc1', '"+formData+"');";
        }
        insertQuery(query, function(data){
            if(data.match(/1/i)){
                notifySucceed("Mise à jour réussie.", "Votre questionnaire a été mis à jour");
            }else{
                notifyFail("Mise à jour échouée.", "Votre questionnaire n'a pas été mis à jour <br><strong>Veuillez réessayer de sauvegarder.</strong>");
            }
            
        })
    });

    $('.edit-form', formContainer).click(function() {
        $fBInstance.toggle();
        $(formContainer).toggle();
    });
}

function loadExistingDocuments(){
    selectQuery("SELECT * FROM typedocument", function(data){
        $.each(data.results, function( index, value ) {
            $(".docSelection").append("<li id='"+value.idtype+"' data-name='"+value.nomtype+"' class='dash' title='"+value.nomtype+"'><span class='nomtype'>"+value.nomtype+"</span><icon class='glyphicon glyphicon-remove delete' data-delete='"+value.idtype+"' data-toggle='modal' data-target='#deleteDoc'></icon> <icon class='glyphicon glyphicon-edit edit' data-edit='"+value.idtype+"' data-toggle='modal' data-target='#editDoc'></icon></li>")
        });
        $(".docSelection li").removeClass("selected");
        $("#"+idDocument+"").addClass("selected");
        $(".docSelection li:not(.newDocument)").click(function(){
            idDocument = $(this).attr("id");
            init();
        })

        $(".docSelection .edit").click(function(){
            var id = $(this).attr("data-edit")
            $("#nomDoc").val($("#"+id).attr("data-name"))
            $("#idDoc").val(id)
        })

        $(".docSelection .delete").click(function(){
            var id = $(this).attr("data-delete")
            console.log(id)
            $("#idDoc").val(id)
        })

        fit();
    })

}

function handleAdd(){
    $("#add").click(function(){
        query = "INSERT INTO typedocument(idtype, nomtype, nomfichier) VALUES (DEFAULT, '"+encodeEntities($("#nom").val())+"', '') RETURNING idtype;";
        selectQuery(query, function(data){
            console.log(data);
            idDocument = data.results[0].idtype
            $("#nom").val("")
            $(".docSelection li:not(.newDocument)").remove();
            loadExistingDocuments();
            init();
        })
    })
    $("#commitChanges").click(function(){
        query = "UPDATE typedocument SET nomtype = '"+encodeEntities($("#nomDoc").val())+"' WHERE idtype = "+$("#idDoc").val()+";";
        insertQuery(query, function(data){
            notifySucceed("Nom modifié","Le nom du questionnaire a été modifié.")
            $(".docSelection li:not(.newDocument)").remove();
            loadExistingDocuments();
        })
    })
    $("#delete").click(function(){
        query = "DELETE FROM typedocument WHERE idtype = "+$("#idDoc").val()+";";
        insertQuery(query, function(data){
            notifySucceed("Document modifié","Le document a été supprimé.")
            $(".docSelection li:not(.newDocument)").remove();
            loadExistingDocuments();
        })
    })
}

function selectQuery(query, success){
    vdata={"dbname":dbname, "user":user, "pw":pw, "query": query};
    $.ajax({
        type: "POST",
        url: '../index.php?type=11',
        contentType: "application/x-www-form-urlencoded;charset=ISO-8859-15",
        data: vdata,
        dataType:"json"
    }).done(function( data ){
        success(data);
    });
}
function insertQuery(query, success){
    vdata={"dbname":dbname, "user":user, "pw":pw,"nomfichier":"Doc1","file":"", "query": query};
    $.ajax({
      type: "POST",
      url: '../index.php?type=20',
      contentType: "application/x-www-form-urlencoded;charset=ISO-8859-15",
      data: vdata
    }).done(function(data){
        success(data);
    });
}

var language = {
        addOption: 'Ajouter une option',
        allFieldsRemoved: 'Vider tous les champs',
        allowSelect: 'Autoriser la selection',
        autocomplete: 'Auto-completion',
        button: 'Boutton',
        cannotBeEmpty: 'Ce champs ne peut pas être vide',
        checkboxGroup: 'Case(s) à cocher',
        checkbox: 'Case à cocher',
        checkboxes: 'Cases à cocher',
        className: 'Nom de la classe CSS',
        clearAllMessage: 'Vider tous les champs',
        clearAll: 'Tout vider',
        close: 'Fermer',
        copy: 'Copier',
        dateField: 'Champs date',
        description: 'Description',
        descriptionField: 'Champs description',
        devMode: 'Mode développeur',
        editNames: 'Editer les noms',
        editorTitle: 'Titre de l\'éditeur',
        editXML: 'Editer le XML',
        fieldDeleteWarning: false,
        fieldVars: 'Variable des champs',
        fieldNonEditable: 'Champs non éditable',
        fieldRemoveWarning: 'Enlever l\'avertissement sur le champs',
        fileUpload: 'Téléversement de fichier',
        formUpdated: 'Mise à jour de formulaire',
        getStarted: 'Pour commencer, glissez un élément ici.',
        hide: 'Cacher',
        hidden: 'Caché',
        label: 'Libellé',
        labelEmpty: 'Libellé vide',
        limitRole: 'Limiter au rôle:',
        mandatory: 'Mandatory',
        maxlength: 'Nombre de caractère maximum',
        minOptionMessage: 'Option minimum de message',
        name: 'Nom',
        no: 'Numéro',
        off: 'Désactiver',
        on: 'Activer',
        option: 'Option',
        optional: 'Optionnel',
        optionLabelPlaceholder: 'Libellé du placeholder de l\'option',
        optionValuePlaceholder: 'Libellé du placeholder de la valeur',
        optionEmpty: 'Option vide',
        paragraph: 'Paragraphe',
        placeholders: {
          value: 'Valeur',
          label: 'Libellé',
          text: 'Texte',
          textarea: 'Texte',
          email: 'Email',
          placeholder: 'Placeholder',
          className: 'Classe css',
          password: 'Mot de passe'
        },
        preview: 'Aperçu',
        radioGroup: 'Groupe de boutons radio',
        radio: 'Radio bouton',
        removeMessage: 'Supprimer le message',
        required: 'Requis',
        richText: 'Texte riche',
        roles: 'Rôle',
        save: 'Sauvegarder',
        selectOptions: 'Sélectionner une option',
        select: 'Sélectionner',
        selectColor: 'Sélectionner une couleur',
        selectionsMessage: 'Sélectionner un message',
        size: 'Taille',
        style: 'Style',
        styles: {
          btn: {
            'default': 'Par défaut',
            danger: 'Danger',
            info: 'Information',
            primary: 'Primaire',
            success: 'Succés',
            warning: 'Avertissement'
          }
        },
        subtype: 'Sous type',
        subtypes: {
          text: ['text', 'password', 'email', 'color'],
          button: ['button', 'submit']
        },
        text: 'Texte',
        textArea: 'Champs texte',
        toggle: 'Déplier',
        warning: 'Avertissement!',
        viewXML: 'Voir le XML',
        yes: 'Oui',
        no: 'Non',
        header: 'Entête'
    };
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
    //console.log($(str).html())
    return str.replace(/[\u00E0-\u00FC\'\""]/gim, function(i) {
       return '&#'+i.charCodeAt(0)+';';
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
function xmlToString(xmlData) { 

    var xmlString;
    //IE
    if (window.ActiveXObject){
        xmlString = xmlData.xml;
    }
    // code for Mozilla, Firefox, Opera, etc.
    else{
        xmlString = (new XMLSerializer()).serializeToString(xmlData);
    }
    return xmlString;
} 

function fit(){
    var p = $('.dash span');
    $('.dash').attr("style", "width:"+$(".docSection").width() - 20+"px");
    var ks = $('.dash').height();
    while ($(p).outerHeight() > ks) {
      $(p).text(function(index, text) {
        return text.replace(/\W*\s(\S)*$/, '...');
      });
    }
}