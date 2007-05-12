NAME=SBAlphaBeta
VERSION=0.2

RELEASENAME=$(NAME)-$(VERSION)
DMG=$(RELEASENAME).dmg

UP=stig@brautaset.org:code/files/
DMGURL=http://code.brautaset.org/files/$(DMG)

site:
	rm -rf build/html
	perl -pi -e 's/#import/#include/' *.h *.m 
	(cat Doxyfile; echo "PROJECT_NUMBER=$(VERSION)") | doxygen -
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' build/html/*.html
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' build/html/*.html
	perl -pi -e 's/#include/#import/' *.h *.m 

upload-site: site
	rsync -ruv --delete build/html/ stig@brautaset.org:code/$(NAME)/

dmg: install
	rm -rf build/tmp/ $(DMG)
	setCFBundleVersion $(VERSION)
	xcodebuild -target $(NAME) clean
	xcodebuild -target Tests
	xcodebuild -target $(NAME) install
	mkdir -p build/tmp
	mv /tmp/Frameworks/$(NAME).framework build/tmp
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder build/tmp $(DMG)

upload-dmg: dmg
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" && echo "$(DMG) already uploaded" || scp $(DMG) $(UP)

