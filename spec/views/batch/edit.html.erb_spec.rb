require 'spec_helper'

describe 'batch/edit.html.erb' do
  let( :batch ) {
    stub_model(Batch, id: '123')
  }

  let(:generic_file) {
    content = double('content', versions: [], mimeType: 'application/pdf')
    stub_model(GenericFile, noid: '123',
               depositor: 'bob',
               content: content)
  }


  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    controller.request.path_parameters[:id] = "123"
    assign :batch, batch
    assign :generic_file, generic_file
    render
    @page = Capybara::Node::Simple.new(rendered)
  end

  it "should draw modal for license" do
    expect(@page).to have_selector("div#myModal .modal-dialog .modal-content", count: 1)
  end

  it "should draw modal for rights" do
    expect(@page).to have_selector("div#rightsModal .modal-dialog .modal-content", count: 1)
  end

end

