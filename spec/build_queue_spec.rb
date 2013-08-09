require 'spec_helper'

module Hudson
  describe BuildQueue do
    describe '#api' do
      it 'should be a Hash' do
        api = BuildQueue.api
        api.class.should eq(Hash)
      end

      it 'should be only jobs[name, color]' do
        jobs = BuildQueue.api('items[task[name]]')
        jobs.keys.should eq(['items'])
      end
    end
  end
end
