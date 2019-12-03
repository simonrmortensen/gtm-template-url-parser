___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "URL Parser",
  "description": "With this variable template, input any complete URL and select which components of the URL you\u0027d like returned.",
  "containerContexts": [
    "WEB"
  ], 
  categories: ["UTILITY"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "inputURL",
    "displayName": "Input a URL or URL Variable",
    "simpleValueType": true,
    "help": "In this field, input a full URL or a URL variable, from which you\u0027d like to extract URL components. For instance, \u003cstrong\u003e{{Click URL}}\u003c/strong\u003e or \u003cstrong\u003e{{Page URL}}\u003c/strong\u003e",
    "valueHint": "e.g. https://iihnordic.com/services/"
  },
  {
    "type": "SELECT",
    "name": "returnComponent",
    "displayName": "Return URL Component",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "protocol",
        "displayValue": "Protocol"
      },
      {
        "value": "hostname",
        "displayValue": "Full Hostname"
      },
      {
        "value": "rootHostname",
        "displayValue": "Root Hostname"
      },
      {
        "value": "uri",
        "displayValue": "Page Path / URI"
      },
      {
        "value": "queryParam",
        "displayValue": "Query Parameter"
      },
      {
        "value": "fragment",
        "displayValue": "Fragment"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "returnUriIndex",
    "checkboxText": "Return a certain Page Path level",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnComponent",
        "paramValue": "uri",
        "type": "EQUALS"
      }
    ],
    "help": "Check this box if you\u0027d like to return a certain part/level of the input Page Path, based on index. Leave unchecked to return the full Page Path."
  },
  {
    "type": "CHECKBOX",
    "name": "inverseIndex",
    "checkboxText": "Use Inverted Indexing",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnUriIndex",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "Check this box if you\u0027d like to use inversed indexing for the query path. If this box is checked, the input \u003cstrong\u003e1\u003c/strong\u003e returns the last page path level, \u003cstrong\u003e2\u003c/strong\u003e returns the second last, etc."
  },
  {
    "type": "TEXT",
    "name": "uriIndex",
    "displayName": "Page Path Index",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnUriIndex",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ],
    "help": "In this field, input the index of the page path level you would like to return (indexing starts at \u003cstrong\u003e1\u003c/strong\u003e). Check \u0027Use Inverted Indexing\u0027 to invert indexing.",
    "valueHint": "e.g. 1 or 2 or -1"
  },
  {
    "type": "TEXT",
    "name": "returnQueryKey",
    "displayName": "Input the Query Parameter key",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnComponent",
        "paramValue": "queryParam",
        "type": "EQUALS"
      }
    ],
    "help": "In this text field, input the key to the URL query parameter whose value you\u0027d like to return",
    "valueHint": "e.g. apikey",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "uriDecode",
    "checkboxText": "URI decode",
    "simpleValueType": true,
    "help": "Check this box if you\u0027d like to URI Decode the output.",
    "defaultValue": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const decodeUriComponent = require("decodeUriComponent");

// Variables
const url = data.inputURL;
const urlIsValid = url.indexOf("http") == 0;
const error = {
	url: "Invalid URL Input"
};

if (!urlIsValid){
	return error.url;
}

let protocol;
let hostname;
let rootHostname;
let uri;
let queries;
let fragment;

// Assignment of each components various values
let urlComponents = [];
urlComponents.push(url.split("?")[0]);
if (url.split("?").length > 1){
  urlComponents.push(url.split("?")[1].split("#")[0]);
} else {
  urlComponents.push("");
}
urlComponents.push(url.split("#")[1]);

let baseURL = urlComponents[0].split("/");
let hostnameComponents = baseURL[2].split(".");

protocol = baseURL[0].split(":")[0].toUpperCase();
hostname = baseURL[2];
rootHostname = hostnameComponents[hostnameComponents.length - 2] + "." + hostnameComponents[hostnameComponents.length - 1];
uri = [];
queries = urlComponents[1].split("&");
fragment = urlComponents[2];

for (var i = 3; i < baseURL.length; i++) {
  uri.push(baseURL[i]);
}
uri = uri.join("/");

// Function returns the variable output selected by user
function getComponent(){
	switch(data.returnComponent){
      case "protocol": 
        return protocol;
      case "hostname":
        return hostname;
      case "rootHostname":
        return rootHostname;
      case "uri":
        if (data.returnUriIndex){
          	let uriComponents = uri.split("/");
        	
          	if (data.inverseIndex){
              	return uriComponents[uriComponents.length - data.uriIndex];
            } else {
            	return uriComponents[data.uriIndex - 1];
            }
        } else {
        	return uri;
        }
        break;
      case "queryParam":
        for (var i = 0; i < queries.length; i++) {
          	let key = queries[i].split("=")[0];
          	let value = queries[i].split("=")[1];

			if (key == data.returnQueryKey){
            	return value;
            }
		}
        break;
      case "fragment":
        return fragment;
    }
}

// Variables must return a value.
const selectedComponent = getComponent();

if (data.uriDecode && selectedComponent){
	return decodeUriComponent(selectedComponent);
} else {
	return selectedComponent;
}


___TESTS___

scenarios: []


___NOTES___

Created on 03/12/2019, 09:47:38


