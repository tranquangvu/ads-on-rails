class ReportFormat

  REPORT_FORMATS = {
    'CSV' => {:name => 'CSV', :content_type => 'text/csv', :postfix => '.csv'},
    'XML' => {:name => 'XML', :content_type => 'text/xml', :postfix => '.xml'},
    'GZIPPED_CSV' => {
        :name => 'Gzipped CSV',
        :content_type => 'application/x-gzip',
        :postfix => '.csv.gz'
    },
    'GZIPPED_XML' => {
        :name => 'Gzipped XML',
        :content_type => 'application/x-gzip',
        :postfix => '.xml.gz'
    }
  }

  attr_reader :type, :name, :content_type, :postfix

  def initialize(type, name, content_type, postfix)
    @type, @name, @content_type, @postfix = type, name, content_type, postfix
  end

  def self.report_format_for_type(format_type)
    report_formats.find{ |x| x.type == format_type }
  end

  def self.report_formats
    @@report_formats ||= get_report_formats
  end

  def file_name(report)
    [report.name, ' Report', @postfix].join()
  end

  private
    def self.get_report_formats
      report_formats = []
      REPORT_FORMATS.each do |k, v|
        report_formats.push(ReportFormat.new(k, v[:name], v[:content_type], v[:postfix]))
      end
      report_formats
    end
end
