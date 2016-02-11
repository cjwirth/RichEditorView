var RichEditorTests = function() {
    var self = this;
    var tests = [];

    var tearDown = function() {
      RE.setHtml('')
    };

    /**
    This is the main and only public "method"
    **/
    self.runTests = function() {
      for (var testName in tests) {
        console.log('Running: ' + testName)
        tests[testName]();
				console.log(testName + ' passed')
        // tearDown()
      }
    }

    tests['testGetSet'] = function() {
      var testContent = "Test"
        RE.setHtml(testContent)
        Assert.equals(RE.getHtml(), testContent, 'testGetSet')
    };

    tests['testGetSelectedHrefReturnsLinkOnFullSelection'] = function() {
      var link = "http://foo.bar/"
      var htmlWithLink = "<a id='link_id' href='"+link+"'>Foo</a>"
      RE.setHtml(htmlWithLink)
      //select the anchor tag directly and fully
      RE.selectElementContents(document.querySelector('#link_id'))
      Assert.equals(RE.getSelectedHref(), link)
    };

    tests['testGetSelectedHrefOnPartialSelection'] = function() {
      var link = "http://foo.bar"
      var anchor = "<a id='link_id' href='"+link+"'>Foo</a>"
      var htmlWithLink = "<span><p id='prose'>What are these so withered and wild in their attire? " + anchor + " </p>that look not like the inhabitants of the Earth and yet are on't?</span>"
      RE.setHtml(htmlWithLink)
      //select the anchor tag directly and fully
      RE.selectElementContents(document.querySelector('#prose'))
      Assert.equals(RE.getSelectedHref(), link)
    };

    return self;
}()

RichEditorTests.runTests()
