use Storable;
store \%table, 'file';
$hashref = retrieve('file');
