RSpec::Matchers.define :have_field do |field|
  chain :of_type do |type|
    @type = type
  end
  
  match do |obj|
    @has_field = obj.class.has_field?(field)

    if @type
      @has_field && obj.class.field_type(field) == @type
    else
      @has_field
    end
  end
end