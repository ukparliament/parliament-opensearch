require_relative '../../spec_helper'

describe Parliament::OpenSearch::DescriptionCache, vcr: true do
  before :each do
    Timecop.freeze(Time.local(2018,4,10,16,0,0))
  end

  after :each do
    subject.instance_variable_set(:@store, nil)

    Timecop.return
  end

  let(:uri) { 'https://beta.parliament.uk/search/opensearch' }

  describe '.fetch' do
    context 'with a valid cache of a description' do
      before :each do
        subject.instance_variable_set(:@store, { uri => { timestamp: Time.local(2018,4,10,16,0,0), templates: ['foo'] } })
      end

      it 'loads from the cache' do
        expect(subject.fetch(uri)).to eq(['foo'])

        expect(WebMock).not_to have_requested(:get, uri)
      end

      context 'that is now expired' do
        before :each do
          Timecop.freeze(Time.local(2018,4,10,16,15,0))
        end

        it 'downloads as expected' do
          expect(subject.fetch(uri)).to eq([{:type=>"text/html", :template=>"http://beta.parliament.uk/search?q={searchTerms}&start_index={startIndex?}&count={count?}"}])

          expect(WebMock).to have_requested(:get, uri)
        end

      end
    end

    context 'without a cached description' do
      it 'gets the description' do
        expect(subject.fetch(uri)).to eq([{:type=>"text/html", :template=>"http://beta.parliament.uk/search?q={searchTerms}&start_index={startIndex?}&count={count?}"}])

        expect(WebMock).to have_requested(:get, uri)
      end
    end
  end

  describe '.delete' do
    context 'after cacheing description' do
      it 'removes it from the store' do
        subject.fetch(uri)

        expect{subject.delete(uri)}.to change{subject.store.size}.by(-1)
      end

      it 'invalidates the cache' do
        subject.fetch(uri)
        subject.delete(uri)
        subject.fetch(uri)

        expect(WebMock).to have_requested(:get, uri).times(2)
      end
    end

  end

end