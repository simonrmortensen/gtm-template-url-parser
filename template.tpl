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
  "categories": ["UTILITY"]
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
        "displayValue": "Root Hostname (Hostname without subdomains)"
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
      },
      {
        "value": "baseURL",
        "displayValue": "Base URL (URL without query parameters and fragments)"
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
    "valueHint": "e.g. 1, 2 or 3 etc."
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
const decode = require("decodeUriComponent");
//const log = require("logToConsole");

// Pre-checks and work
const url = data.inputURL;
const urlIsValid = url.indexOf("http") == 0;
const error = {
	input: "Invalid URL Input"
};

if (!urlIsValid){
	return undefined;
}

// Initial breakdown of the URL
let urlComponents = [];
const urlHasQueries = url.indexOf("?") != -1;
const urlHasFragment = url.indexOf("#") != -1;

if (urlHasQueries && urlHasFragment){
    urlComponents.push(url.substring(0, url.indexOf("?")));
    urlComponents.push(url.substring(url.indexOf("?") + 1, url.indexOf("#")));
    urlComponents.push(url.substring(url.indexOf("#") + 1));
} else if (!urlHasQueries && urlHasFragment){
	urlComponents.push(url.substring(0, url.indexOf("#")));
  	urlComponents.push("");
  	urlComponents.push(url.substring(url.indexOf("#") + 1));
} else if (urlHasQueries && !urlHasFragment){
    urlComponents.push(url.substring(0, url.indexOf("?")));
  	urlComponents.push(url.substring(url.indexOf("?") + 1));
  	urlComponents.push("");
} else {
	urlComponents.push(url);
	urlComponents.push("");
	urlComponents.push("");
}

const baseURL = urlComponents[0].split("/");
const hostnameComponents = baseURL[2].split(".");

// Assignment of each components various values
const protocol = baseURL[0];
const hostname = baseURL[2];
let rootHostname = hostnameComponents.slice(hostnameComponents.length - 2).join(".");
const uri = baseURL.filter(x => x).slice(2);
const queries = urlComponents[1];
const fragment = urlComponents[2];

if (rootHostname == "co.uk") {
	rootHostname = hostnameComponents.slice(hostnameComponents.length - 3).join(".");
}

// Function returns the variable output selected by user
function getComponent(){
	switch(data.returnComponent){
      case "protocol": 
        return protocol.split(":")[0].toUpperCase();
      case "hostname":
        return hostname;
      case "rootHostname":
        return rootHostname;
      case "uri":
        if (data.returnUriIndex){
        	return data.inverseIndex ? uri[uri.length - data.uriIndex] : uri[data.uriIndex - 1];
        } else {
        	return uri.join("/");
        }
        break;
      case "queryParam":
        const keyExists = queries.split(data.returnQueryKey + "=")[1];
        return keyExists ? keyExists.split("&")[0] : undefined;
      case "fragment":
        return fragment;
      case "baseURL":
        return baseURL.join("/");
    }
}

// Variables must return a value.
const selectedComponent = getComponent();
return data.uriDecode && selectedComponent ? decode(selectedComponent) : selectedComponent;


___TESTS___

scenarios: []


___NOTES___

Created on 04/12/2019, 10:45:23


