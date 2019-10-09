\ EdHtmlPreview.f
\ Edit Html source and preview in an Html window

\ 0 value PreviewChild		\ create preview object
\
\ : HtmlPreview	{ \ child -- }
\ 		ActiveChild 0= ?exit
\ 		GetFileType: ActiveChild FT_SOURCE <> ?exit
\ 		SaveFile: ActiveChild 	\ save edit first
\ 		GetFileName: ActiveChild c@ 0= ?exit   \ saving was cancelled
\ 		ActiveChild to Child
\ 		PreviewChild 0=
\ 		if	NewHtmlWnd ActiveChild to PreviewChild
\ 		then	GetHandle: PreviewChild Activate: Frame
\ 		GetFileName: Child count asciiz SetURL: PreviewChild
\ 		Update ; IDM_HTML_PREVIEW SetCommand


needs HtmlDisplayWindow.f

HtmlDisplayWindow PreviewWindow

: HtmlPreview	{ \ child -- }
		ActiveChild 0= ?exit
		GetFileType: ActiveChild FT_SOURCE <> ?exit
		SaveFile: ActiveChild 	\ save edit first
		GetFileName: ActiveChild c@ 0= ?exit   \ saving was cancelled
		GetHandle: MainWindow SetParentWindow: PreviewWindow
		Start: PreviewWindow
		GetFileName: ActiveChild count over SetUrl: PreviewWindow
		s" HtmlPreview - " pad place pad +place
		pad count SetText: PreviewWindow ; IDM_HTML_PREVIEW SetCommand

create HtmlDefaultSource ," <html>\n<head>\n    <title>Untitled</title>\n</head>\n\n<body>\n\n</body>\n</html>" 32 allot

: NewHtmlFile	( -- )
		NewEditWnd	\ start a new window
		HtmlDefaultSource count SetTextZ: ActiveChild ; IDM_NEW_HTML_SOURCE_FILE SetCommand
\s

