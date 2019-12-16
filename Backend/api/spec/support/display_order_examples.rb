require 'spec_helper'

RSpec.shared_examples 'display order' do
  let(:item) {
    item = described_class.new
    item.displayOrder = 1
    item
  }

  it 'sets display order' do
    expect(item.displayOrder).to eq 1
  end

  it 'sets the extension data properly' do
    ext = item.extension.find do
      |ext| ext['url'] == Extensions::DisplayOrder::URL
    end

    expect(ext['valueInteger']).to eq 1
  end
end
