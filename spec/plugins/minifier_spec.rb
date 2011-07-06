require "spec_helper"

describe BPM::Pipeline, 'minifier' do

  before do
    goto_home
    set_host
    reset_libgems bpm_dir.to_s
    start_fake(FakeGemServer.new)
    
    FileUtils.cp_r fixtures('minitest'), '.'
    cd home('minitest')

    bpm 'compile'
    wait
  end
  
  subject do
    project = BPM::Project.new home('minitest')
    BPM::Pipeline.new project, :production
  end
  
  it "should wrap bpm_packages.js" do
    asset = subject.find_asset 'bpm_packages.js'
    file_path = home('minitest', 'packages', 'uglyduck', 'lib', 'main.js')
    expected = <<EOF
//MINIFIED START
UGLY DUCK IS UGLY
/* ===========================================================================
   BPM Static Dependencies
   MANIFEST: uglyduck (1.0.0)
   This file is generated automatically by the bpm (http://www.bpmjs.org)    
   To use this file, load this file in your HTML head.
   =========================================================================*/

#{File.read file_path}
//MINIFIED END
EOF

    asset.to_s.should == expected
  end

  it "should wrap app_package.js" do
    asset = subject.find_asset 'minitest/app_package.js'
    file_path = home('minitest', 'lib', 'main.js')
    expected = <<EOF
//MINIFIED START
UGLY DUCK IS UGLY
/* ===========================================================================
   BPM Static Dependencies
   MANIFEST: minitest (2.0.0)
   This file is generated automatically by the bpm (http://www.bpmjs.org)    
   To use this file, load this file in your HTML head.
   =========================================================================*/

#{File.read(file_path)}
//MINIFIED END
EOF
    asset.to_s.should == expected
  end

  subject do
    project = BPM::Project.new home('minitest')
    BPM::Pipeline.new project, :production
  end
  
  it "should not wrap bpm_packages.js in debug mode" do
    project  = BPM::Project.new home('minitest')
    pipeline = BPM::Pipeline.new project, :debug
    asset    = pipeline.find_asset 'minitest/app_package.js'
    asset.to_s.should_not include('//MINIFIED START')
  end
  
end

  