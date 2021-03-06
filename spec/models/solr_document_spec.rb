require "spec_helper"
require "json"

describe SolrDocument do

  describe "#get_availibility_info" do

    it "knows the url to hit for location" do
      ENV['AVAILABILITY_SERVICE'] = "//apps.whatever.test.edu/bibutils/bib/"
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.location_data_url).to start_with("https://apps")
      expect(solrdoc.location_data_url).to end_with("bibutils/bib/b123456")
    end

    it "returns nil availability_info if http call is nil" do
      SolrDocument.class_eval do
        def make_http_call url
          nil
        end
      end
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.get_availability_info).to be nil
    end

    it "parses JSON availability_info" do
      SolrDocument.class_eval do
        def make_http_call url
          JSON.generate({"items" => [{"location" => "ROCK"}]})
        end
      end
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.get_availability_info["items"]).to eq [{"location" => "ROCK"}]
    end

  end

  describe "#to_sms_text" do

    def stub_get_availability_info_nil
      SolrDocument.class_eval do
        def get_availability_info
          nil
        end
      end
    end

    it "creates basic sms text" do
      stub_get_availability_info_nil
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title")
    end

    it "creates sms text with callnumber" do
      SolrDocument.class_eval do
        def get_availability_info
          {"items" => [{"callnumber" => "AB12 .C3"}]}
        end
      end
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title\nAB12 .C3")
    end

    it "creates sms text with location info" do
      SolrDocument.class_eval do
        def get_availability_info
          {"items" => [{"location" => "ROCK"}]}
        end
      end
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title\nLocation: ROCK")
    end

    it "creates sms text with call number and location" do
      SolrDocument.class_eval do
        def get_availability_info
          {"items" => [{"callnumber" => "AB12 .C3", "location" => "ROCK"}]}
        end
      end
      solrdoc = SolrDocument.new(source_doc={"title_display" => ["test title"]})
      expect(solrdoc.to_sms_text).to eq("test title\nAB12 .C3\nLocation: ROCK")
    end
  end

  describe "#has_toc?" do

    it "handles empty solr data" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.has_toc?).to be false
    end

    it "handles solr data with no toc" do
      solrdoc = SolrDocument.new(source_doc={"id" => "b123456"})
      expect(solrdoc.has_toc?).to be false
    end

    it "handles 505 toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_display" => ["test toc"]})
      expect(solrdoc.has_toc?).to be true
    end

    it "handles 970 toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_970_display" => ["test toc"]})
      expect(solrdoc.has_toc?).to be true
    end

    it "handles both kinds of toc" do
      solrdoc = SolrDocument.new(source_doc={"toc_display" => ["test 505 toc"], "toc_970_display" => ["test 970 toc"]})
      expect(solrdoc.has_toc?).to be true
    end

  end

  describe "#get_toc" do

      it "returns TableOfContents object with 970 info" do
        solrdoc = SolrDocument.new(source_doc={"toc_970_display" => [JSON.generate([{"title" => "970"}])]})
        expect(solrdoc.get_toc.chapters[0]["title"]).to eq("970")
      end

      it "returns TableOfContents object with 505 info" do
        solrdoc = SolrDocument.new(source_doc={"toc_display" => [JSON.generate([{"title" => "505"}])]})
        expect(solrdoc.get_toc.chapters[0]["title"]).to eq("505")
      end

  end

  describe "has_uniform_titles?" do

    it "handles empty solr doc" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.has_uniform_titles?).to be false
    end

    it "checks for all uniform titles solr fields" do
      solrdoc = SolrDocument.new(source_doc={"uniform_titles_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
      expect(solrdoc.has_uniform_titles?).to be true
      solrdoc = SolrDocument.new(source_doc={"new_uniform_title_author_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
      expect(solrdoc.has_uniform_titles?).to be true
    end

  end

  describe "has_related_works?" do

    it "handles empty solr doc" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.has_related_works?).to be false
    end

    it "checks for related works solr fields" do
      solrdoc = SolrDocument.new(source_doc={"uniform_related_works_display" => [JSON.generate([{"title" => [{"query" => "", "display" => ""}]}])]})
      expect(solrdoc.has_related_works?).to be true
    end

  end

  describe "get_uniform_titles" do

    it "handles empty solr doc" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.get_uniform_titles).to eq([])
    end

    it "gets uniform titles" do
      uniform_titles_display = [JSON.generate([{"title" => [{"query" => "q", "display" => "d"}]}])]
      new_uniform_title_author_display = [JSON.generate([{"title" => [{"query" => "q2", "display" => "d2"}]}])]
      uniform_related_works_display = [JSON.generate([{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}])]
      src_doc = {"author_display" => "doc_author"}
      src_doc["uniform_titles_display"] = uniform_titles_display
      src_doc["new_uniform_title_author_display"] = new_uniform_title_author_display
      src_doc["uniform_related_works_display"] = uniform_related_works_display
      solrdoc = SolrDocument.new(source_doc=src_doc)
      expected_titles = [{"title" => [{"query" => "q", "display" => "d"}]}]
      expected_titles << {"title" => [{"query" => "q2", "display" => "d2"}], "author" => "doc_author"}
      expect(solrdoc.get_uniform_titles).to eq(expected_titles)
    end

  end

  describe "get_related_works" do

    it "handles empty solr doc" do
      solrdoc = SolrDocument.new(source_doc={})
      expect(solrdoc.get_related_works).to eq([])
    end

    it "gets related works" do
      uniform_related_works_display = [JSON.generate([{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}])]
      src_doc = {"uniform_related_works_display" => uniform_related_works_display}
      solrdoc = SolrDocument.new(source_doc=src_doc)
      related_works = [{"title" => [{"query" => "q3", "display" => "d3"}], "author" => "title_author"}]
      expect(solrdoc.get_related_works).to eq(related_works)
    end

  end

  describe "marc extraction methods" do
    it "abstract" do
      marc_display_string = File.read("./spec/data/item_marc.json")
      solr_doc = SolrDocument.new({"marc_display" => marc_display_string})
      expect(solr_doc.full_abstract).to eq ["abstract1", "abstract2"]
    end

    it "item data" do
      marc_display_string = File.read("./spec/data/item_marc.json")
      solr_doc = SolrDocument.new({"marc_display" => marc_display_string})
      item_data = solr_doc.item_data

      bookplate1 = item_data.select do |i|
        i.barcode == "barcode1" &&
        i.bookplate_code = "bookplate1" &&
        i.bookplate_url = "http://bookplate1" &&
        i.bookplate_display = "Gift of barcode1"
      end
      expect(bookplate1.count).to eq(1)

      nodata = item_data.select {|i| i.barcode.nil? && i.location_code.nil?}
      expect(nodata.count).to eq(1)

      rock = item_data.select {|i| i.location_code == "rock"}
      expect(rock.count).to eq(1)
    end
  end
end

describe TableOfContents do

  describe "#chapters" do

    it "knows its chapters" do
      toc = TableOfContents.new([JSON.generate([{"title" => "test title"}])], nil)
      expect(toc.chapters[0]["title"]).to eq("test title")
    end

    it "fills in missing keys as needed" do
      toc = TableOfContents.new([JSON.generate([{}])], nil)
      expect(toc.chapters[0]["label"]).to eq("")
      expect(toc.chapters[0]["indent"]).to eq("")
      expect(toc.chapters[0]["authors"]).to eq([])
      expect(toc.chapters[0]["title"]).to eq("")
      expect(toc.chapters[0]["page"]).to eq("")
    end

    it "handles 505 data" do
      toc = TableOfContents.new(nil, [JSON.generate([{"title" => "test title"}])])
      expect(toc.chapters[0]["title"]).to eq("test title")
    end

    it "defaults to 970 instead of 505" do
      toc = TableOfContents.new([JSON.generate([{"title" => "970 title"}])], [JSON.generate([{"title" => "505 title"}])])
      expect(toc.chapters[0]["title"]).to eq("970 title")
    end

  end

end
