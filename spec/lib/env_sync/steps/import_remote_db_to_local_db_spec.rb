RSpec.describe EnvSync::Steps::ImportRemoteDbToLocalDb do
  subject(:step) { described_class.new(settings) }

  let(:settings) { EnvSync::Settings.new }

  before do
    settings.load_settings_file('spec/support/settings_with_all_steps.yml')
  end

  it 'does not execute the command if the step should not be run' do
    settings.steps.delete(:import_remote_db_to_local_db)
    command = successful_command_stub

    step.run

    expect(command).not_to have_received(:execute)
  end

  context 'when the step should be run and the source file is valid' do
    before do
      db_conn_config_stub
      allow(File).to receive(:exist?).and_return(true)
    end

    it 'executes the command' do
      command = successful_command_stub

      step.run

      expect(command).to have_received(:execute)
    end

    context 'when the command is successfully executed' do
      it 'sets the message' do
        successful_command_stub

        step.run

        expect(step.message).to eq('Imported remote DB to local DB.')
      end

      it 'updates the success variable' do
        successful_command_stub

        step.run

        expect(step.success).to be true
      end
    end

    context 'when the command execution fails' do
      it 'sets the message' do
        failed_successful_command_stub

        step.run

        expect(step.message).to eq('Remote DB to local DB import failed.')
      end

      it 'sets the success variable' do
        failed_successful_command_stub

        step.run

        expect(step.success).to be false
      end
    end
  end

  context 'when the step should be run and the source file is not valid' do
    before do
      db_conn_config_stub
      allow(File).to receive(:exist?).and_return(false)
    end

    it 'sets the message' do
      step.run

      expect(step.message).to eq('Missing remote DB dump file')
    end

    it 'does not update the success variable' do
      step.run

      expect(step.success).to be false
    end

    it 'does not execute the command' do
      command = failed_successful_command_stub

      step.run

      expect(command).not_to have_received(:execute)
    end
  end
end
