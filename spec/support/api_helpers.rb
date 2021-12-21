module ApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def do_request(method, path, **options)
    send method, path,
         params: options[:params],
         headers: options[:headers],
         env: options[:env],
         xhr: options[:xhr],
         as: :json
  end
end
