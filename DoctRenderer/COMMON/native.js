var editor = undefined;
var window = new Object();
var navigator = new Object();
navigator.userAgent = "chrome";
window.navigator = navigator;
window.location = new Object();

window.location.protocol = "";
window.location.host = "";
window.location.href = "";

window.NATIVE_EDITOR_ENJINE = true;
window.NATIVE_EDITOR_ENJINE_SYNC_RECALC = true;

window.__fonts_files = __fonts_files;
window.__fonts_infos = __fonts_infos;

var document = new Object();
window.document = document;

function Image()
{
    this.src = "";
    this.onload = function()
    {
    }
    this.onerror = function()
    {
    }
}

function _image_data()
{
    this.data = null;
    this.length = 0;
}

function native_context2d(parent)
{
    this.canvas = parent;

    this.globalAlpha = 0;
    this.globalCompositeOperation = "";
    this.fillStyle = "";
    this.strokeStyle = "";

    this.lineWidth = 0;
    this.lineCap = 0;
    this.lineJoin = 0;
    this.miterLimit = 0;
    this.shadowOffsetX = 0;
    this.shadowOffsetY = 0;
    this.shadowBlur = 0;
    this.shadowColor = 0;
    this.font = "";
    this.textAlign = 0;
    this.textBaseline = 0;
}
native_context2d.prototype =
{
    save : function() {},
    restore : function() {},

    scale : function(x,y) {},
    rotate : function(angle) {},
    translate : function(x,y) {},
    transform : function(m11,m12,m21,m22,dx,dy) {},
    setTransform : function(m11,m12,m21,m22,dx,dy) {},

    createLinearGradient : function(x0,y0,x1,y1) { return null; },
    createRadialGradient : function(x0,y0,r0,x1,y1,r1) { return null; },
    createPattern : function(image,repetition) { return null; },

    clearRect : function(x,y,w,h) {},
    fillRect : function(x,y,w,h) {},
    strokeRect : function(x,y,w,h) {},

    beginPath : function() {},
    closePath : function() {},
    moveTo : function(x,y) {},
    lineTo : function(x,y) {},
    quadraticCurveTo : function(cpx,cpy,x,y) {},
    bezierCurveTo : function(cp1x,cp1y,cp2x,cp2y,x,y) {},
    arcTo : function(x1,y1,x2,y2,radius) {},
    rect : function(x,y,w,h) {},
    arc : function(x,y,radius,startAngle,endAngle,anticlockwise) {},

    fill : function() {},
    stroke : function() {},
    clip : function() {},
    isPointInPath : function(x,y) {},
    drawFocusRing : function(element,xCaret,yCaret,canDrawCustom) {},

    fillText : function(text,x,y,maxWidth) {},
    strokeText : function(text,x,y,maxWidth) {},
    measureText : function(text) {},

    drawImage : function(img_elem,dx_or_sx,dy_or_sy,dw_or_sw,dh_or_sh,dx,dy,dw,dh) {},

    createImageData : function(imagedata_or_sw,sh) 
    { 
        var _data = new _image_data();
        _data.length = imagedata_or_sw * sh * 4;
        _data.data = new Uint8Array(imagedata_or_sw * sh * 4);
        return _data;
    },
    getImageData : function(sx,sy,sw,sh) {},
    putImageData : function(image_data,dx,dy,dirtyX,dirtyY,dirtyWidth,dirtyHeight) {}
};

function native_canvas()
{
    this.id = "";
    this.width = 300;
    this.height = 150;
}
native_canvas.prototype =
{
    getContext : function(type)
    {
        if (type == "2d")
            return new native_context2d(this);
        return null;
    },

    toDataUrl : function(type)
    {
        return "";
    },
    
    addEventListener : function()
    {
    },
    
    attr : function()
    {
    } 
};

window["Asc"] = new Object();

var _null_object = new Object();
_null_object.length = 0;
_null_object.nodeType = 1;
_null_object.offsetWidth = 1;
_null_object.offsetHeight = 1;
_null_object.clientWidth = 1;
_null_object.clientHeight = 1;
_null_object.scrollWidth = 1;
_null_object.scrollHeight = 1;
_null_object.style = new Object();
_null_object.documentElement = _null_object;
_null_object.body = _null_object;
_null_object.addEventListener = function(){};
_null_object.setAttribute = function(){};
_null_object.getElementsByTagName = function() { return []; };
_null_object.appendChild = function() {};
_null_object.removeChild = function() {};
_null_object.insertBefore = function() {};
_null_object.childNodes = [];
_null_object.parent = _null_object;
_null_object.parentNode = _null_object;
_null_object.find = function() { return this; };
_null_object.appendTo = function() { return this; };
_null_object.css = function() { return this; };
_null_object.width = function() { return 0; };
_null_object.height = function() { return 0; };
_null_object.attr = function() { return this; };
_null_object.remove = function() {};

document.createElement = function(type)
{
    if (type && type.toLowerCase)
    {
        if (type.toLowerCase() == "canvas")
            return new native_canvas();
    }
    
    return _null_object;
}

function _return_empty_html_element() { return _null_object; };

document.createDocumentFragment = _return_empty_html_element;
document.getElementsByTagName = function(tag) { 
    var ret = [];
    if ("head" == tag)
        ret.push(_null_object);
    return ret;
};
document.insertBefore = function() {};
document.appendChild = function() {};
document.removeChild = function() {};
document.getElementById = function() { return undefined; };
document.createComment = function() { return undefined; };

document.documentElement = _null_object;
document.body = _null_object;

var native = CreateNativeEngine();
window.native = native;

var native_renderer = null;
var _api = null;

function NativeOpenFile()
{
    if (NATIVE_DOCUMENT_TYPE == "presentation" || NATIVE_DOCUMENT_TYPE == "document")
    {
        _api = new asc_docs_api("");
        _api.DocumentUrl = "TeamlabNative";
        
        window.editor.ImageLoader = new Object();
        window.editor.ImageLoader.map_image_index = {};
        
        window.editor.CoAuthoringApi = new Object();
        window.editor.CoAuthoringApi.saveChanges = function(){};

        var doc_bin = window.native.GetFileString(g_file_path);
        _api.OpenDocument2("", doc_bin);
        
        //var doc_bin = window.native.GetFileBinary(g_file_path);
        //_api.OpenDocument("", doc_bin);
    }
    else
    {
        _api = new spreadsheet_api("", "");
        _api.DocumentUrl = "TeamlabNative";
        
        Asc["editor"] = _api;
        
        _api.User = new Asc["asc_CUser"];
		_api.User.asc_setId("TM");
		_api.User.asc_setUserName("native");
        
        window.asc_wb = new Workbook(_api.DocumentUrl, _api.handlers, _api);   
        _api.initGlobalObjects(window.asc_wb);
        _api.wbModel = window.asc_wb;
        var oBinaryFileReader = new BinaryFileReader(_api.DocumentUrl);   
        var doc_bin = window.native.GetFileString(g_file_path);
        oBinaryFileReader.Read(doc_bin, window.asc_wb);
        
        _api.wb = new Asc["WorkbookView"](
					_api.wbModel,
					_api.controller,
					_api.handlers,
					_null_object,
					_null_object,
					_api,
					_api.collaborativeEditing,
					_api.fontRenderingMode,
					_api.options);
    }
}

function NativeCalculateFile()
{
    if (NATIVE_DOCUMENT_TYPE == "presentation" || NATIVE_DOCUMENT_TYPE == "document")
    {
        _api.OpenDocumentEndCallback();
        window.editor.ShowParaMarks = false;
    }
    else
    {				
		window.adjustPrint = new asc_CAdjustPrint();
        window.printPagesData = _api.wb.calcPagesPrint(window.adjustPrint);
    }
}

function NativeApplyChanges()
{
    if (NATIVE_DOCUMENT_TYPE == "presentation" || NATIVE_DOCUMENT_TYPE == "document")
    {
        var _count_main = window.native.GetCountChanges();
        for (var i = 0; i < _count_main; i++)
        {
            var _changes_file = window.native.GetChangesFile(i);
            var _changes = JSON.parse(window.native.GetFileString(_changes_file));

            for (var j = 0; j < _changes.length; j++)
            {     
                var Changes = new CCollaborativeChanges();
                Changes.Set_Id( _changes[j]["id"] );
                Changes.Set_Data( _changes[j]["data"] );
                CollaborativeEditing.Add_Changes( Changes );   
            }
        }
        CollaborativeEditing.Apply_OtherChanges();
    }
    else
    {
        var __changes = [];
        var _count_main = window.native.GetCountChanges();
        for (var i = 0; i < _count_main; i++)
        {
            var _changes_file = window.native.GetChangesFile(i);
            var _changes = JSON.parse(window.native.GetFileString(_changes_file));

            for (var j = 0; j < _changes.length; j++)
            {     
                __changes.push(_changes[j]);   
            }
        }
        
        _api._coAuthoringInit();
        _api.CoAuthoringApi.onSaveChanges(__changes, false);
        _api.collaborativeEditing.applyChanges();
    }    
}
function NativeGetFileString()
{
    if (NATIVE_DOCUMENT_TYPE == "presentation")
    {
        var writer = new CBinaryFileWriter();
        window.editor.WordControl.m_oLogicDocument.CalculateComments();
        return writer.WriteDocument(window.editor.WordControl.m_oLogicDocument);
    }
    else if (NATIVE_DOCUMENT_TYPE == "document")
    {
        var oBinaryFileWriter = new BinaryFileWriter(window.editor.WordControl.m_oLogicDocument);
        return oBinaryFileWriter.Write();
    }
    else
    {
        _api.wb._initCommentsToSave();
		var oBinaryFileWriter = new BinaryFileWriter(_api.wbModel);
		return oBinaryFileWriter.Write();
    }
}

function GetNativeCountPages()
{
    if (NATIVE_DOCUMENT_TYPE == "document")
        return window.editor.WordControl.m_oDrawingDocument.m_lPagesCount;
    else if (NATIVE_DOCUMENT_TYPE == "presentation")
        return window.editor.WordControl.m_oDrawingDocument.SlidesCount;
    else
        return 1;
}

function GetNativePageBase64(pageIndex)
{
    if (NATIVE_DOCUMENT_TYPE == "presentation" || NATIVE_DOCUMENT_TYPE == "document")
    {
        if (native_renderer == null)
        {
            native_renderer = new CDocumentRenderer();
            //native_renderer.Memory				= new CMemory();
            //native_renderer.VectorMemoryForPrint	= new CMemory();
            
            native_renderer.Memory					= CreateNativeMemoryStream();
            native_renderer.VectorMemoryForPrint	= CreateNativeMemoryStream();
        }
        else
        {
            native_renderer.Memory.ClearNoAttack();
            native_renderer.VectorMemoryForPrint.ClearNoAttack();
        }
        
        if (NATIVE_DOCUMENT_TYPE == "presentation")
        {
            var _logic_doc = window.editor.WordControl.m_oLogicDocument;
            native_renderer.BeginPage(_logic_doc.Width, _logic_doc.Height);
            window.editor.WordControl.m_oLogicDocument.DrawPage(pageIndex, native_renderer);
            native_renderer.EndPage();    
        }
        else if (NATIVE_DOCUMENT_TYPE == "document")
        {
            var page = window.editor.WordControl.m_oDrawingDocument.m_arrPages[pageIndex];
            native_renderer.BeginPage(page.width_mm, page.height_mm);
            window.editor.WordControl.m_oLogicDocument.DrawPage(pageIndex, native_renderer);
            native_renderer.EndPage();
        }
    }
    else
    {
        // TODO: �������� �� ���������� ������
        if (native_renderer == null)
        {
            native_renderer = new CPdfPrinter(_api.wbModel.sUrlPath);
            
            native_renderer.DocumentRenderer.Memory					= CreateNativeMemoryStream();
            native_renderer.DocumentRenderer.VectorMemoryForPrint	= CreateNativeMemoryStream();
        }
        else
        {
            native_renderer.DocumentRenderer.Memory.ClearNoAttack();
            native_renderer.DocumentRenderer.VectorMemoryForPrint.ClearNoAttack();
        }
        
        var isEndPrint = _api.wb.printSheet(native_renderer, window.printPagesData);
        return native_renderer.DocumentRenderer.Memory;
    }

    //return native_renderer.Memory.GetBase64Memory();    
    return native_renderer.Memory;
}

function GetNativeId()
{
    return window.native.GetFileId();
}

function clearTimeout() {};
function setTimeout() {};
function clearInterval() {};
function setInterval() {};

window.clearTimeout = clearTimeout;
window.setTimeout = setTimeout;
window.clearInterval = clearInterval;
window.setInterval = setInterval;