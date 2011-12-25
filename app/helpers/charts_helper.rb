module ChartsHelper
  NL_FIELDS = %w(finishs_count reads_count fails_count bounces_count sendings_per_second)

  def newsletters_chart(newsletters)
    {}.tap do |data|
      NL_FIELDS.each do |method|
        data[method] = []
      end
      newsletters.each do |newsletter|
        date = newsletter.delivery_started_at.to_i * 1000
        NL_FIELDS.each do |method|
          data[method] << [date, newsletter.send(method)]
        end
      end
    end
  end

  def recipients_chart(account)
    {
      :pending   => get_recipients(account.id, 'pending', 'created_at'),
      :confirmed => get_recipients_all(account.id, ['confirmed', 'deleted']),
      :deleted   => get_recipients(account.id, 'deleted', 'updated_at'),
    }
  end

  #private
  def get_recipients(account_id, state, field = 'created_at')
    Recipient.connection.execute("Set time_zone = '+0:00'")
    Recipient.connection.select_rows <<-SQL
      SELECT
        UNIX_TIMESTAMP(DATE_FORMAT(#{field}, '%Y-%m-%d')) AS `date`,
        COUNT(*) AS cnt
      FROM recipients
      WHERE state = '#{state}'
      GROUP BY `date`
      ORDER BY `date` ASC
    SQL
  end

  def get_recipients_all(account_id, states = [])
    Recipient.connection.execute("Set time_zone = '+0:00'")
    Recipient.connection.select_rows <<-SQL
      SELECT
       UNIX_TIMESTAMP(`date`) AS `date`,
       MAX(IF(cnt > 0,cnt,0)) + Min(IF(cnt < 0,cnt,0)) AS cnt
      FROM
        (SELECT
           DATE_FORMAT(created_at, '%Y-%m-%d') AS `date`,
           COUNT(*) AS cnt
         FROM recipients
         WHERE account_id = #{account_id} AND state IN('#{states.join("','")}')
         GROUP BY `date`

        UNION

         SELECT
           DATE_FORMAT(updated_at, '%Y-%m-%d') AS `date`,
           -1 * COUNT(*) AS cnt
         FROM recipients
         WHERE account_id = #{account_id} AND state = '#{states.last}'
         GROUP BY `date`) AS u
      GROUP BY `date`
      ORDER BY `date`
    SQL
  end

  def send_outs_chart(account)
     opts = {
      15.minutes => "&lt; 15min",
      1.hour     => "15min - 1h",
      3.hours    => "1h - 3h",
      12.hours   => "3h - 12h",
      1.day      => "12h - 24h",
      2.day      => "24h - 48h",
      100.days   => "&gt; 48h"
    }
    newsletter_ids = account.newsletters.map(&:id)
    {
      :read_diff => {
        :opts => opts,
        :data => get_read_diff(newsletter_ids, opts),
      },
      :read_span => get_read_span(newsletter_ids),
    }
  end

  def get_read_diff(newsletter_ids, opts)
    return [] unless newsletter_ids.any?
    min = opts.keys.min
    Recipient.connection.select_rows <<-SQL
      SELECT TIME_TO_SEC(TIMEDIFF(updated_at, IFNULL(finished_at, created_at))) DIV #{min} * #{min} AS `date`,
      COUNT(*)
      FROM send_outs
      WHERE state = 'read'
      AND newsletter_id IN(#{newsletter_ids.join(',')})
      GROUP BY `date`
    SQL
  end

  def get_read_span(newsletter_ids, span = 10.minutes)
    return [] unless newsletter_ids.any?
    Recipient.connection.execute("Set time_zone = '+0:00'")
    Recipient.connection.select_rows <<-SQL
      SELECT
      UNIX_TIMESTAMP(DATE_FORMAT(updated_at, "2011-01-01 %H:%i")) DIV #{span} AS `date`,
      COUNT(*)
      FROM send_outs
      WHERE state = 'read'
      AND newsletter_id IN(#{newsletter_ids.join(',')})
      GROUP BY `date`
    SQL
  end
end
