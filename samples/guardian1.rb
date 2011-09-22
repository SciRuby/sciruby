dat = SciRuby.dataset :guardian, 'gla-sector-employment-projections-2009'

label_width = 30
w = 1000
label_height = 40
h = 600

t = Rubyvis::Scale.linear(dat["Year"].min, dat["Year"].max).range(label_width, w)
y = Rubyvis::Scale.linear(0, dat["Business services"].max).range(label_height, h)
f = Rubyvis::Scale.ordinal(dat.fields).range('red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet')

coords = dat["Year"].zip(dat["Business services"])

::Rubyvis::Panel.new do
  width w
  height h

  rule do
    data dat["Year"]
    stroke_style { |d| d>1971 ? '#CCC' : 'red' }
    bottom label_height
    left { |d| t.scale(d) }
  end.anchor('bottom').add(::Rubyvis::Label).
      text_angle(-Math::PI / 2.0).
      text_baseline('middle').text_align('right')

  rule do
    data [0,500000,1000000,1500000]
    stroke_style { |d| d>0 ? '#CCC' : 'red'}
    bottom { |d| y.scale(d) }
    left label_width
    right 0
  end.anchor('left').add(::Rubyvis::Label).
      text_angle(-Math::PI / 2.0).
      text_align('center').text_baseline('right').left(15)


  dat.fields.each do |field|
    next if field == "Year"
    coords = dat["Year"].zip(dat[field])
    line do
      data coords
      stroke_style lambda { f.scale(field) }
      left { |d| t.scale(d[0]) }
      bottom { |d| y.scale(d[1]) }
    end.anchor('right').add(::Rubyvis::Label).
        visible{ |d| d[0] == 1971 }.
        text_style('#666').
        text(lambda { field })
  end
end