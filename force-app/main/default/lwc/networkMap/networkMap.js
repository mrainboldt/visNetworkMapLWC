import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import locale from '@salesforce/i18n/locale';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { fireEvent } from 'c/pubsub';
import visNetwork from '@salesforce/resourceUrl/visNetwork';
import visData from '@salesforce/resourceUrl/visData';
import handlebars from '@salesforce/resourceUrl/handlebars';
import slds from '@salesforce/resourceUrl/SLDS262';
import getRelationships from '@salesforce/apex/NetworkMapExtension.getRelationships';
import createEdge from '@salesforce/apex/NetworkMapExtension.createEdge';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
const fields = [FIRSTNAME_FIELD, LASTNAME_FIELD];

export default class NetworkMapVisJS extends LightningElement {
    //LOCAL
    resourcesLoaded = false;
    relationshipsLoaded = false;
    nodes;
    edges;
    iconurlbase = slds + '/icons/';
    iconurlmid = '/svg/symbols.svg#';
    fromNodeId;
    root;

    //API  
    @api recordId;

    //TRACK
    @track loading;
    @track network;
    @track canvas;
    @track defaultVariant;
    @track hierarchyVariant;
    @track groups;

    @wire(getRecord, { recordId: '$recordId', fields })
    record;

    @wire(getRelationships, {recordId: '$recordId'})
     wiredRelationships({error, data})
     {
        if(data) 
        {
            let dataSet = JSON.parse(data);
            this.formatData(dataSet);
            this.relationshipsLoaded = true;
            this.checkLoadStatus();
        }
        else
        {
            console.log('Getting Relationships Error:' + error);
            this.showErrorToast('Error getting relationships', error);
        }
     }

    get contactName() {
        return getFieldValue(this.record.data, FIRSTNAME_FIELD) + ' ' + getFieldValue(this.record.data, LASTNAME_FIELD);
    }

    constructor() {
        super();
        this.resourcesLoaded = false;
        this.relationshipsLoaded = false;
        this.loading = true;
        this.nodes = [];
        this.edges = [];
        this.defaultVariant = 'brand';
        this.hierarchyVariant = 'neutral';
        this.groups = [];
        this.root = undefined;

    }

    connectedCallback(){
        //this.getCanvas();
        
        Promise.all([
            loadScript(this, handlebars)
            , loadScript(this, visData + '/esnext/umd/vis-data.js')
            , loadScript(this, visNetwork + '/peer/umd/vis-network.js')
            , loadStyle(this, visNetwork + '/styles/vis-network.min.css')
           // , loadStyle(this, slds)
        ]).then(() => {
                console.log('then');
                this.resourcesLoaded = true;
                console.log('calling check load status');
                this.checkLoadStatus();
                console.log('called check load status');;
        })
        .catch(error => {
            this.loading = false;
            console.log('Error Initializing...'+JSON.stringify(error));
            this.showErrorToast('Error Intializing', error);
        });
    }

    checkLoadStatus(){
        if(this.resourcesLoaded === true
             && this.relationshipsLoaded === true)
        {
            this.initialize();
        }
    }

    createDataSets(nodes, edges)
    {
        
        let visNodes = new vis.DataSet(nodes, {filter: this.filterNodes});
        let visEdges = new vis.DataSet(edges);

        return {nodes: visNodes, edges: visEdges}
    }

    createEdge(edge)
    {
        this.loading = true;
        console.log(edge);
        if( edge
            && edge.source
            && edge.to){
            createEdge({ edgeJson: JSON.stringify(edge)
                    , recordId: this.recordId})
            .then(result => {
                this.edges.push(JSON.parse(result));
                this.network.edges = new vis.DataSet(this.edges);
                this.fromNodeId = null;
                this.loading = false;
            })
            .catch(error => {
                console.log('Error creating edge:' + JSON.stringify(error));
                this.showErrorToast('Error creating edge', error);
            });
        }
        else{
            this.loading = false;
        }
        
    }

    createHierarchyVisualization(){
        let options, nodes, edges, div;
        
        // Configuration for the Network
        options = this.getHierarchyOptions();
        div = this.template.querySelector('[data-id="vis-network"]');
        div.width = window.innerWidth;
        div.height = window.innerHeight;

        this.createNetwork(this.createDataSets(this.nodes,this.edges), options);
    }

    createNetwork(data, options)
    {
        let root;
        data.nodes.forEach((item) => {
            if(item.id === this.recordId)
            {
                root = item.id;
                return;
            }
        }, this);
        options.layout.randomSeed = root;
        this.network = new vis.Network(this.template.querySelector('[data-id="vis-network"]'), data, options);
        // options.physics.enabled = false;
        // this.network.setOptions(options);
        this.network.parent = this;
        this.loading = false;
    }

    /**
     * initialize timeline visualization
     */
    createNetworkVisualization()
    {
        let options, div;
        // Configuration for the Network
        options = this.getNetworkOptions();
        div = this.template.querySelector('[data-id="vis-network"]');
        div.width = window.innerWidth;
        div.height = window.innerHeight;
    
        this.createNetwork(this.createDataSets(this.nodes, this.edges), options);

        this.network.on("click", function (params) {
            params.event = "[original event]";
            console.log('click: ' + JSON.stringify(params));
            //document.getElementById('eventSpan').innerHTML = '<h2>Click event:</h2>' + JSON.stringify(params, null, 4);
            console.log('click event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
        });
        this.network.on("doubleClick", function (params) {
            params.event = "[original event]";
            console.log('doubleClick: ' + JSON.stringify(params));
            //document.getElementById('eventSpan').innerHTML = '<h2>doubleClick event:</h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("oncontext", function (params) {
            params.event = "[original event]";
            console.log('oncontext: ' + JSON.stringify(params));
            //document.getElementById('eventSpan').innerHTML = '<h2>oncontext (right click) event:</h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("dragStart", function (params) {
            // There's no point in displaying this event on screen, it gets immediately overwritten
            params.event = "[original event]";
            console.log('dragStart Event:', params);
            console.log('dragStart event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
        });
        this.network.on("dragging", function (params) {
            params.event = "[original event]";
            //this.parent.template.querySelector('eventSpan').innerHTML = '<h2>dragging event:</h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("dragEnd", function (params) {
            params.event = "[original event]";
            
            console.log('dragEnd: ' + JSON.stringify(params));
            //this.parent.template.querySelector('eventSpan').innerHTML = '<h2>dragEnd event:</h2>' + JSON.stringify(params, null, 4);
            console.log('dragEnd Event:', params);
            console.log('dragEnd event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
        });
        this.network.on("controlNodeDragging", function (params) {
            params.event = "[original event]";
            console.log('controlNodeDragging: ' + JSON.stringify(params));
            this.parent.fromNodeId = params.controlEdge.from;
            //this.parent.template.querySelector('eventSpan').innerHTML = '<h2>control node dragging event:</h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("controlNodeDragEnd", function (params) {
            var fromId, toId, edge;
            if(!params) return;
            params.event = "[original event]";
            edge = {};
            edge.source = this.parent.fromNodeId;
            edge.to = params.controlEdge.to;
            this.parent.createEdge(edge);
            //this.parent.template.querySelector('eventSpan').innerHTML = '<h2>control node drag end event:</h2>' + JSON.stringify(params, null, 4);
            console.log('controlNodeDragEnd Event:', params);
        });
        this.network.on("zoom", function (params) {
            //document.getElementById('eventSpan').innerHTML = '<h2>zoom event:</h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("showPopup", function (self, params) {
            console.log('showPopup Event');
            //document.getElementById('eventSpan').innerHTML = '<h2>showPopup event: </h2>' + JSON.stringify(params, null, 4);
        });
        this.network.on("hidePopup", function () {
            console.log('hidePopup Event');
        });
        this.network.on("select", function (params) {
            console.log('select Event:', params);
        });
        this.network.on("selectNode", function (params) {
            console.log('selectNode Event:', params);
        });
        this.network.on("selectEdge", function (params) {
            console.log('selectEdge Event:', params);
        });
        this.network.on("deselectNode", function (params) {
            console.log('deselectNode Event:', params);
        });
        this.network.on("deselectEdge", function (params) {
            console.log('deselectEdge Event:', params);
        });
        this.network.on("hoverNode", function (params) {
            console.log('hoverNode Event:', params);
        });
        this.network.on("hoverEdge", function (params) {
            console.log('hoverEdge Event:', params);
        });
        this.network.on("blurNode", function (params) {
            console.log('blurNode Event:', params);
        });
        this.network.on("blurEdge", function (params) {
            console.log('blurEdge Event:', params);
        });
    }

    filterNodes(node)
    {
        var exclude = true;
        var context = this.parent ? this.parent : this;
        context.groups.forEach(function(group){
            if(node.groupId === group.value)
            {
                exclude = !group.isActive;
            }
        },  context);

        return exclude;
    }

    formatData(dataSet)
    {
        var groupIds = [];
        dataSet.nodes.forEach(function(item){
            item.group = item.groupLabel;
            item.physics = false;
            if(!groupIds.includes(item.groupId)){
                var groupOption = {
                    value: item.groupId,
                    label: item.groupLabel,
                    isActive: true
                };
                groupIds.push(item.groupId);
                this.groups.push(groupOption);
            }
            if(!item.image)
            {
                item.image = this.iconurlbase + item.imageName;
            }
            
            this.nodes.push(item);
        }, this);
        dataSet.edges.forEach(function(item){
            var edge = {};
            edge.from = item.source;
            edge.to = item.to;
            edge.id = item.id;
            edge.value = item.weight ? item.weight : -1;
            edge.label = item.label;
            edge.hidden = item.hidden;
            edge.font = {
                align: 'bottom'
                , face: "'Salesforce Sans', 'arial', 'sans-seri'"
                , size: 9
                , bold: false
                , bold: false
                , strokeWidth: 0
            };
            edge.font.mono = {size: 10};
            this.edges.push(edge);
        }, this);
    }

    getCanvas() {
        if (!this.canvas) {
          this.canvas = document.createElement('canvas');
          this.canvas.width = window.innerWidth;
          this.canvas.height = window.innerHeight;
          this.template.querySelector('[data-id="vis-network"]').appendChild(this.canvas);
        }
        return this.canvas;
    }

    getDefaultOptions()
    {
        let groups = {};
        let options = {
            autoResize: true
            , width: '100%'
            , height: '100%'
            , physics: false
        };
        //interaction
        options.interaction = {
            dragNodes: true
            , dragView: true
            , zoomView: true
        };
        options.layout = {
            randomSeed: this.root
            , improvedLayout: true
        }
        this.groups.forEach(function(item){
            groups[item.label] = {color:{background: '#97c2fc'
                                        , border: '#3f88eb'}
                                };
        }, this);
        options.groups = groups;

        return options;
    }

    getHierarchyOptions()
    {
        let options = this.getDefaultOptions();
        options.edges = {
            forceDirection: 'vertical'
            , smooth: {type: 'cubicBezier'}
        };
        options.physics = {
            enabled: false
        };
        options.layout.hierarchical = {direction: 'UD'
                                    , sortMethod: 'directed'
                                };

        return options;
    }

    getNetworkOptions(){
        let options = this.getDefaultOptions();
        options.physics = {
            enabled: true
            ,stabilization: {
                enabled: true
                , fit: true
            }
            , solver : 'forceAtlas2Based'
        };
        // //options.physics.enabled = false;
        options.edges = {
            smooth: false
        }
        options.manipulation = {
            enabled: true
            , addEdge: true
            , addNode: false
        };
        // options.configure = {};
        // options.configure.filter = true;
        // options.configure.showButton = true;

        return options;
    }

    handleGroupSelect(event)
    {
        console.log(event);
        const selectedItemValue = event.currentTarget.value;
        this.groups.forEach(function(group){
            if(group.value === selectedItemValue)
            {
                group.isActive = !group.isActive;
                return;
            }
        });
        this.network.body.data.nodes.forEach((item) => {
            item.hidden = this.filterNodes(item);
        }, this);
        this.network.setData({nodes: this.network.body.data.nodes, edges: this.network.body.data.edges});
    }

    /**
     * @description all the actions required to initialize the timeline
     */
    initialize ()
    {
        this.loading = true;
        try{
            this.createNetworkVisualization();
            
            this.loading = false;
        }catch(exception)
        {
            console.log('Error intitializing...' + exception);
            this.showErrorToast('Error Intitializing', exception);
        }
    }

    renderDefault(event){
        this.loading = true;
        this.defaultVariant = 'brand';
        this.hierarchyVariant = 'neutral';
        this.createNetworkVisualization();
    }

    renderHierarchy(event){
        this.loading = true;
        this.defaultVariant = 'neutral';
        this.hierarchyVariant = 'brand';
        
        this.createHierarchyVisualization();
    }

    /**
     * @description general error handling and display toast
     */
    showErrorToast(title, error)
    {
        var stackTrace;
        if (error && error.body && Array.isArray(error.body)) {
            error = error.body.map(e => e.message).join(', ');
        } else if (error && error.body && typeof error.body.message === 'string') {
            stackTrace = error.body.stackTrace;
            error = error.body.message;
            if(stackTrace)
            {
                error = error + ' (' + stackTrace + ')';
            }
        }
        else if(error && typeof error.message === 'string')
        {
            error = error.message;
            if(error.stackTrace)
            {
                error = error + '(' + error.stackTrace + ')';
            }
        }
        
        error = error ? error : 'error occurred';
        this.showToast(title, error, 'error', 'sticky');
    }

    /**
     * @description generic toast handling
     */
    showToast(title, message, variant, mode)
    {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            }),
        );
    }

    
}