\ $Id: PVFileAssociations.f,v 1.1 2006/07/24 21:22:37 rodoakford Exp $

\ PVFileAssociations.f


Needs FileAssociations.f

: SetJPG ( -- )   s" .jpg"  s" JPG Image"  s" PictureViewer.exe"  SetAssociation ;
: DeleteJPG ( -- )   s" .jpg"  s" PictureViewer.exe"  DeleteAssociation ;

