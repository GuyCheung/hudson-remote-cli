require 'spec_helper'

module Hudson
  describe System do
    describe '#api' do
      it 'should be a Hash' do
        api = Hudson.api
        puts api if Debug
        api.class.should eq(Hash)
      end

      it 'should be only jobs[name, color]' do
        jobs = Hudson.api('jobs[name,color]')
        puts jobs if Debug
        jobs.keys.should eq(['jobs'])
      end
    end

    describe '#overallLoad' do
      it 'should be 4 keys at least' do
        api = Hudson.overallLoad
        puts api if Debug
        (%w{busyExecutors queueLength totalExecutors totalQueueLength} -
          api.keys).should eq([])
      end
    end
  end
end
