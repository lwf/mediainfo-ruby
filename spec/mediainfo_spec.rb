require "#{File.dirname(__FILE__)}/../lib/mediainfo-ruby"
describe MediaInfoLib::MediaInfo do
	VIDEO_FIXTURES = "#{File.dirname(__FILE__)}/fixtures"
	
	before(:all) do
		@video_files = Dir.new(VIDEO_FIXTURES).collect{|f|
			f unless f[0..0] == "." || f.include?(".swf") || f.include?("flv")
		}.compact
		if @video_files.length == 0
			puts "Please put some video files on spec/fixtures to test"
		end
	end
	context "When getting video files" do
		before(:each) do
			@mediainfo = MediaInfoLib::MediaInfo.new
		end
		after(:each) do
			@mediainfo.close
		end
		it "Can open local files" do
			@video_files.each{|video|
				@mediainfo.open("#{VIDEO_FIXTURES}/#{video}").should > 0
				@mediainfo.inform.length.should > 0
			}
		end
		it "Can get info from files" do
			@video_files.each{|video|
				@mediainfo.open("#{VIDEO_FIXTURES}/#{video}").should > 0
				@mediainfo.streams.should > 0
				@mediainfo.streams.should < 1000
				#@mediainfo.get(MediaInfoLib_StreamKind::General,1,0,MediaInfoLib_InfoKind::Name).should_not be_nil
			}
		end
		it "Can get the option definitions for a file" do
				definitions = @mediainfo.option_definitions
				[:general, :audio, :video, :text, :chapters, :menu, :text, :image].each{|topic|
        	# All these topics should be there
					definitions.keys.should include(topic)
        	# All these topics should have more than one item
					definitions[topic].keys.length.should > 0
				}
				#pp definitions
		end
		it "Can get the Media Info values for a file" do
			@video_files.each{|video|
				@mediainfo.open("#{VIDEO_FIXTURES}/#{video}").should > 0
				values = @mediainfo.introspect
				#puts "Streams for #{video}: Video:#{@mediainfo.video_streams} Audio:#{@mediainfo.audio_streams} Image:#{@mediainfo.image_streams}"
				if @mediainfo.video_streams > 0
					[:general, :audio, :video, :text, :chapters, :menu, :text, :image].each{|topic| values.should include(topic)}
        	# TODO Spot check some topics.
					values[:general].keys.length.should > 0
					values[:general]["CodecID"].should_not be_nil
					values[:general]["CodecID"].should_not include("TODO")
					#pp values
				end
			}
		end
	end

end
