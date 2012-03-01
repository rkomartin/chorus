chorus.views.DashboardInstanceList = chorus.views.Base.extend({
    constructorName: "DashboardInstanceListView",
    className:"dashboard_instance_list",
    tagName:"ul",
    additionalClass:"list",
    useLoadingSection:true,

    collectionModelContext: function(model) {
        return { 
            imageUrl: model.providerIconUrl(),
            isHadoop: model.isHadoop()
        }
    },

    postRender: function() {
        var self = this;
        this.$("li").each(function(i, li) {
            var id = $(li).data("id");
            var instance = self.collection.get(id);
            $(li).find("a[data-dialog='SchemaBrowser']").data("instance", {
                id: instance.get("id"),
                name: instance.get("name")
            });
        })
    }
});

