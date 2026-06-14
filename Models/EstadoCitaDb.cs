using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("EstadosCita")]
public class EstadoCitaDb
{
    [Key]
    public int IdEstado { get; set; }
    [Required, MaxLength(50)]
    public string Nombre { get; set; } = string.Empty;
}
