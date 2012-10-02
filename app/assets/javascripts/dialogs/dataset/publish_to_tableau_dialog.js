chorus.dialogs.PublishToTableau = chorus.dialogs.Base.extend({
    constructorName: "PublishTableau",

    templateName:"publish_to_tableau_dialog",
    title: 'Publish to Tableau',

    events:{
        "click button.submit": "publishToTableau"
    },

    setup: function() {
        this.bindings.add(this.model, "saved", this.saveSuccess);
        this.bindings.add(this.model, "saveFailed", this.saveFailed);
        this.bindings.add(this.model, "validationFailed", this.saveFailed);
    },

    publishToTableau: function() {
        this.model.set({name: this.$("input[name='name']").val()});
        this.$("button.submit").startLoading('actions.publishing');
        this.$("button.cancel").prop("disabled", true);
        this.model.save();
    },

    saveSuccess: function() {
        chorus.toast("tableau.published",
            {
                objectType: this.model.get('dataset').humanType(),
                objectName: this.model.get('dataset').shortName(20),
                name: this.model.shortName(20)
            });
        this.closeModal();
    },

    saveFailed: function() {
        this.$("button.submit").stopLoading();
        this.$("button.cancel").prop("disabled", false);
    }
});