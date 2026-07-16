require 'rails_helper'

RSpec.describe ApplicationService, type: :service do
  describe '#call' do
    it 'raises NotImplementedError' do
      service = Class.new(ApplicationService).new
      expect { service.call }.to raise_error(NotImplementedError, "Subclasses must implement the #call method")
    end
  end

  describe '#success_result' do
    it 'returns a success result hash' do
      service = ApplicationService.new
      data = { key: 'value' }
      result = service.send(:success_result, data)

      expect(result).to eq(success: true, data: data, errors: nil)
    end
  end

  describe '#failure_result' do
    it 'returns a failure result hash' do
      service = ApplicationService.new
      errors = { error: 'Something went wrong' }
      result = service.send(:failure_result, errors)

      expect(result).to eq(success: false, data: nil, errors: errors)
    end
  end

  describe '#validate_with_schema' do
    let(:schema_class) { double('SchemaClass') }

    it 'returns success result when validation passes' do
      service = ApplicationService.new
      data = { key: 'value' }
      allow(schema_class).to receive(:call).with(data.to_h).and_return(double(success?: true, to_h: data))

      result = service.send(:validate_with_schema, schema_class, data)

      expect(result).to eq(success: true, data: data, errors: nil)
    end

    it 'returns failure result when validation fails' do
      service = ApplicationService.new
      errors = { error: 'Invalid data' }
      allow(schema_class).to receive(:call).with({}).and_return(double(success?: false, errors: errors))

      result = service.send(:validate_with_schema, schema_class, {})

      expect(result).to eq(success: false, data: nil, errors: errors)
    end
  end
end
