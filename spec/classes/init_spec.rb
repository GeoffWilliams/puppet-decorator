require 'spec_helper'
describe 'decorator' do

  context 'with default values for all parameters' do
    it { should contain_class('decorator') }
  end
end
