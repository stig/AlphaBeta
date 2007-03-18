
NAME=SBAlphaBeta
VERSION=0.1
RELEASENAME=$(NAME)-$(VERSION)
DMG=$(RELEASENAME).dmg

doc:
	rm -rf build/html
	perl -pi -e 's/#import/#include/' *.h *.m 
	(cat Doxyfile; echo "PROJECT_NUMBER=$(VERSION)") | doxygen -
	perl -pi -e 's/#include/#import/' *.h *.m 

upload-doc: doc
	rsync -ruv --delete --exclude download* build/html/ brautaset.org:code/$(NAME)/

install:
	xcodebuild -target SBPerceptron install
	sudo rm -rf ~/Library/Frameworks/$(NAME).framework
	mv /tmp/Frameworks/$(NAME).framework \
		~/Library/Frameworks/$(NAME).framework

dmg:
	rm -rf build/Release/$(NAME).framework build/tmp/
	xcodebuild -target Tests
	mkdir -p build/tmp
	mv build/Release/$(NAME).framework build/tmp
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder build/tmp $(DMG)

upload-dmg: dmg
	scp $(DMG) brautaset.org:code/$(NAME)/download/
