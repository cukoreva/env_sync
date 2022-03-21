RSpec.describe EnvSync::Steps::DownloadRemoteDbDump do
  subject(:step) { described_class.new(step_definition) }

  let(:step_definitions) { EnvSync::StepDefinitions.new }
  let(:loaded_step_definitions) do
    step_definitions.load_step_definitions_file('spec/support/step_definitions_with_all_steps.yml')
  end
  let(:step_definition) { loaded_step_definitions.dig(:steps, :download_remote_db_dump) }

  context 'when the S3 credentials are missing' do
    before { loaded_step_definitions[:steps][:download_remote_db_dump].delete(:s3_credentials) }

    it 'does not execute the command' do
      command = successful_command_stub

      step.run

      expect(command).not_to have_received(:execute)
    end

    it 'sets the message' do
      step.run

      expect(step.message).to eq('Missing S3 credentials in config')
    end

    it 'does not update the success variable' do
      step.run

      expect(step.success).to be false
    end
  end

  context 'when the S3 credentials are present' do
    it 'downloads the S3 object' do
      s3_object = s3_object_stub

      step.run

      expect(s3_object).to have_received(:download_file)
    end

    it 'sets the message' do
      s3_object_stub

      step.run

      expect(step.message).to include('downloaded')
    end

    it 'sets the success variable' do
      s3_object_stub

      step.run

      expect(step.success).to be true
    end
  end
end
