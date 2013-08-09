require 'spec_helper'

module Hudson
  describe Job, Build do
    let (:job_name) { 'hudson-remote-cli-test' }
    let (:job_conf) { File.join(File.dirname(__FILE__), 'config.xml') }

    describe '#create' do
      it 'should be a new job in test hudson' do
        Hudson::Job.create job_name, job_conf
        Hudson.jobs.include?(job_name).should be_true
      end
    end

    describe 'Job Actions' do
      before(:each) do
        @job = Hudson::Job.new(job_name)
      end

      it 'should be job_name' do
        @job.name.should eq(job_name)
      end

      context 'job enable/disable test' do
        after(:each) { @job.enable }

        it 'should be enabled' do
          @job.enable
          @job.buildable?.should be_true
        end

        it 'should be disabled' do
          @job.disable
          @job.buildable?.should be_false
        end
      end

      context 'job description set/get' do
        it 'shoud be "test success"' do
          @job.description = 'test success'
          @job.description.should eq('test success')
        end
      end

      context 'job build/active/lastnumber test' do
        before(:each) do
          @job.wait_for_build
          @last_number = @job.last_build
        end

        it 'should be trigger a build' do
          @job.build!
          last_number = @job.last_build
          (last_number - @last_number).should eq(1)
        end
      end
    end

    describe 'build test' do
      before(:each) do
        @build = Hudson::Build.new(job_name)
      end

      it 'should be 1' do
        @build.number.should eq(1)
      end

      it 'should be suit for the time in record' do
        (10 - (@build.end_time - @build.start_time)).should < 2
      end
    end

    describe '#delete' do
      it 'should be no test_job more' do
        @job = Hudson::Job.new(job_name)
        @job.delete
        Hudson.jobs.include?(job_name).should be_false
      end
    end
  end
end
