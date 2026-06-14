using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("TipoAsegurado")]
public class TipoAsegurado
{
    [Key]
    public int IdTipo { get; set; }
    [Required, MaxLength(50)]
    public string Nombre { get; set; } = string.Empty;
}
